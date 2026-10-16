# Imagen creada por Cloud Build antes de terraform apply.
locals {
  notification_image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry}/notification-cloud-run:latest"
}

# Canal donde el backend publica solicitudes de correo.
resource "google_pubsub_topic" "notifications" {
  name       = "userflow-notifications"
  depends_on = [google_project_service.apis]
}

# Una sola identidad para ejecutar la Cloud Run y recibir mensajes de Pub/Sub.
resource "google_service_account" "notification" {
  account_id   = "userflow-notification"
  display_name = "UserFlow Notifications"
}

# El backend actual solo necesita publicar.
resource "google_project_iam_member" "backend_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Credenciales SMTP protegidas en Secret Manager.
resource "google_secret_manager_secret" "smtp_user" {
  secret_id = "userflow-smtp-user"
  replication {
    auto {}
  }
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
}

resource "google_secret_manager_secret_version" "smtp_password" {
  secret      = google_secret_manager_secret.smtp_password.id
  secret_data = var.smtp_password
}

resource "google_secret_manager_secret_iam_member" "smtp_access" {
  # Las claves son fijas para que Terraform pueda calcular el for_each en plan.
  for_each = {
    user     = google_secret_manager_secret.smtp_user.id
    password = google_secret_manager_secret.smtp_password.id
  }
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.notification.email}"
}

resource "google_project_iam_member" "notification_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.notification.email}"
}

# Servicio privado: solamente Pub/Sub recibe permiso para invocarlo.
resource "google_cloud_run_v2_service" "notification" {
  name                = "notification-cloud-run"
  location            = var.region
  deletion_protection = false

  template {
    service_account = google_service_account.notification.email
    containers {
      image = local.notification_image
      ports {
        container_port = 8080
      }
      env {
        name  = "SMTP_HOST"
        value = var.smtp_host
      }
      env {
        name  = "SMTP_PORT"
        value = "587"
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

  depends_on = [google_secret_manager_secret_iam_member.smtp_access]
}

resource "google_cloud_run_v2_service_iam_member" "pubsub_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.notification.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.notification.email}"
}

# Pub/Sub necesita firmar el token OIDC enviado a Cloud Run.
resource "google_project_service_identity" "pubsub" {
  provider = google-beta
  project  = var.project_id
  service  = "pubsub.googleapis.com"
}

resource "google_service_account_iam_member" "pubsub_token" {
  service_account_id = google_service_account.notification.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_project_service_identity.pubsub.email}"
}

# Convierte cada mensaje publicado en un POST autenticado.
resource "google_pubsub_subscription" "notification" {
  name  = "userflow-notifications-push"
  topic = google_pubsub_topic.notifications.id

  push_config {
    push_endpoint = "${google_cloud_run_v2_service.notification.uri}/pubsub/push"
    oidc_token {
      service_account_email = google_service_account.notification.email
      audience              = google_cloud_run_v2_service.notification.uri
    }
  }

  depends_on = [
    google_cloud_run_v2_service_iam_member.pubsub_invoker,
    google_service_account_iam_member.pubsub_token
  ]
}
