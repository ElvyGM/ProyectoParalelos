locals {
  image_url              = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry}/userflow-api:${var.image_tag}"
  generated_database_url = "Host=/cloudsql/${google_sql_database_instance.postgres.connection_name};Database=${google_sql_database.database.name};Username=${google_sql_user.app.name};Password=${random_password.database.result};Pooling=true"
  effective_database_url = var.database_url != "" ? var.database_url : local.generated_database_url
}

resource "google_project_service" "apis" {
  for_each = toset([
    "apigateway.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "pubsub.googleapis.com"
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = var.artifact_registry
  description   = "Imágenes Docker de UserFlow"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}

resource "google_service_account" "cloud_run" {
  account_id   = "userflow-cloud-run"
  display_name = "UserFlow Cloud Run"
  depends_on   = [google_project_service.apis]
}

resource "google_service_account" "api_gateway" {
  account_id   = "userflow-api-gateway"
  display_name = "UserFlow API Gateway"
  depends_on   = [google_project_service.apis]
}

resource "google_service_account" "cloud_build" {
  account_id   = "userflow-cloud-build"
  display_name = "UserFlow Cloud Build"
  depends_on   = [google_project_service.apis]
}

resource "google_project_iam_member" "build_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "build_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "build_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "run_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "random_password" "database" {
  length  = 24
  special = false
}

resource "google_sql_database_instance" "postgres" {
  name                = "userflow-postgres"
  region              = var.region
  database_version    = "POSTGRES_16"
  deletion_protection = false

  settings {
    edition           = "ENTERPRISE"
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 10
    disk_autoresize   = true
    backup_configuration { enabled = true }
    ip_configuration { ipv4_enabled = true }
  }
  depends_on = [google_project_service.apis]
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "app" {
  name     = var.database_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.database.result
}

resource "google_secret_manager_secret" "database_url" {
  secret_id = "userflow-database-url"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "database_url" {
  secret      = google_secret_manager_secret.database_url.id
  secret_data = local.effective_database_url
}

resource "google_secret_manager_secret" "jwt" {
  secret_id = "userflow-jwt-secret"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "jwt" {
  secret      = google_secret_manager_secret.jwt.id
  secret_data = var.jwt_secret
}

resource "google_secret_manager_secret_iam_member" "run_database" {
  secret_id = google_secret_manager_secret.database_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_secret_manager_secret_iam_member" "run_jwt" {
  secret_id = google_secret_manager_secret.jwt.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_storage_bucket" "uploads" {
  name                        = "${var.project_id}-userflow-files"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  depends_on                  = [google_project_service.apis]
}

resource "google_cloud_run_v2_service" "api" {
  name     = var.cloud_run_service
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run.email
    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }
    containers {
      image = local.image_url
      ports { container_port = 8080 }
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "JWT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.jwt.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "Jwt__Issuer"
        value = "UserFlow.Api"
      }
      env {
        name  = "Jwt__Audience"
        value = "UserFlow.Mobile"
      }
      env {
        name  = "GCS_BUCKET"
        value = google_storage_bucket.uploads.name
      }
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
      env {
  name  = "GCP_PROJECT_ID"
  value = var.project_id
}

env {
  name  = "PUBSUB_TOPIC_ID"
  value = google_pubsub_topic.notifications.name
}
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance { instances = [google_sql_database_instance.postgres.connection_name] }
    }
  }
  depends_on = [google_artifact_registry_repository.docker, google_secret_manager_secret_iam_member.run_database, google_secret_manager_secret_iam_member.run_jwt]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  name     = google_cloud_run_v2_service.api.name
  location = google_cloud_run_v2_service.api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_api_gateway_api" "api" {
  provider     = google-beta
  api_id       = "userflow-api"
  display_name = "UserFlow API"
  depends_on   = [google_project_service.apis]
}

resource "google_api_gateway_api_config" "config" {
  provider             = google-beta
  api                  = google_api_gateway_api.api.api_id
  api_config_id_prefix = "userflow-config-"
  display_name         = "UserFlow API config"
  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = base64encode(templatefile("${path.module}/openapi.yaml.tftpl", { backend_url = google_cloud_run_v2_service.api.uri }))
    }
  }
  lifecycle { create_before_destroy = true }
}

resource "google_api_gateway_gateway" "gateway" {
  provider     = google-beta
  api_config   = google_api_gateway_api_config.config.id
  gateway_id   = "userflow-gateway"
  region       = var.region
  display_name = "UserFlow Gateway"
}

resource "google_logging_metric" "api_errors" {
  name   = "userflow-api-errors"
  filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_service}\" AND severity>=ERROR"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
  depends_on = [google_project_service.apis]
}
