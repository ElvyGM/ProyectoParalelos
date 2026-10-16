data "google_project" "current" {
  project_id = var.project_id
}

locals {
  notification_image_url = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry}/notification-cloud-run:${var.notification_image_tag}"
}

resource "google_pubsub_topic" "notifications" {
  name    = var.notification_topic_name
  project = var.project_id

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_service_account" "notification_run" {
  account_id   = "userflow-notification-run"
  display_name = "UserFlow Notification Cloud Run"

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_service_account" "pubsub_invoker" {
  account_id   = "userflow-pubsub-invoker"
  display_name = "UserFlow PubSub Cloud Run Invoker"

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_project_iam_member" "backend_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "notification_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.notification_run.email}"
}

resource "google_secret_manager_secret" "smtp_user" {
  secret_id = "userflow-smtp-user"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_secret_manager_secret_version" "smtp_user" {
  secret      = google_secret_manager_secret.smtp_user.id
  secret_data = var.smtp_user
}

resource "google_secret_manager_secret" "smtp_password" {
  secret_id = "userflow-smtp-password"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_secret_manager_secret_version" "smtp_password" {
  secret      = google_secret_manager_secret.smtp_password.id
  secret_data = var.smtp_password
}

resource "google_secret_manager_secret_iam_member" "notification_smtp_user" {
  secret_id = google_secret_manager_secret.smtp_user.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.notification_run.email}"
}

resource "google_secret_manager_secret_iam_member" "notification_smtp_password" {
  secret_id = google_secret_manager_secret.smtp_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.notification_run.email}"
}

resource "google_cloud_run_v2_service" "notifications" {
  name     = var.notification_service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.notification_run.email

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    containers {
      image = local.notification_image_url

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "SMTP_HOST"
        value = var.smtp_host
      }

      env {
        name  = "SMTP_PORT"
        value = tostring(var.smtp_port)
      }

      env {
        name = "SMTP_USER"

        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.smtp_user.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "SMTP_PASSWORD"

        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.smtp_password.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    google_artifact_registry_repository.docker,
    google_secret_manager_secret_iam_member.notification_smtp_user,
    google_secret_manager_secret_iam_member.notification_smtp_password
  ]
}

resource "google_cloud_run_v2_service_iam_member" "notification_invoker" {
  project  = var.project_id
  location = google_cloud_run_v2_service.notifications.location
  name     = google_cloud_run_v2_service.notifications.name

  role   = "roles/run.invoker"
  member = "serviceAccount:${google_service_account.pubsub_invoker.email}"
}

resource "google_project_service_identity" "pubsub_agent" {
  provider = google-beta
  project  = var.project_id
  service  = "pubsub.googleapis.com"
}

resource "google_service_account_iam_member" "pubsub_token_creator" {
  service_account_id = google_service_account.pubsub_invoker.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_project_service_identity.pubsub_agent.email}"
}

resource "google_pubsub_subscription" "notification_push" {
  name  = var.notification_subscription_name
  topic = google_pubsub_topic.notifications.id

  ack_deadline_seconds = 60

  push_config {
    push_endpoint = "${google_cloud_run_v2_service.notifications.uri}/pubsub/push"

    oidc_token {
      service_account_email = google_service_account.pubsub_invoker.email
      audience              = google_cloud_run_v2_service.notifications.uri
    }

    attributes = {
      x-goog-version = "v1"
    }
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "60s"
  }

  expiration_policy {
    ttl = ""
  }

  depends_on = [
    google_cloud_run_v2_service_iam_member.notification_invoker,
    google_service_account_iam_member.pubsub_token_creator
  ]
}

resource "google_logging_metric" "notification_errors" {
  name = "userflow-notification-errors"

  filter = join(" ", [
    "resource.type=\"cloud_run_revision\"",
    "resource.labels.service_name=\"${var.notification_service_name}\"",
    "severity>=ERROR"
  ])

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }

  depends_on = [
    google_project_service.apis
  ]
}