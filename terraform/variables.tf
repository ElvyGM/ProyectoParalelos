variable "project_id" {
  description = "ID del proyecto de Google Cloud."
  type        = string
}

variable "region" {
  description = "Región para Cloud Run, Artifact Registry y API Gateway."
  type        = string
  default     = "us-central1"
}

variable "artifact_registry" {
  description = "Nombre del repositorio Docker."
  type        = string
  default     = "userflow"
}

variable "cloud_run_service" {
  description = "Nombre del servicio Cloud Run."
  type        = string
  default     = "userflow-api"
}

variable "image_tag" {
  description = "Etiqueta de la imagen publicada por Cloud Build."
  type        = string
  default     = "latest"
}

variable "database_name" {
  type    = string
  default = "userflow"
}

variable "database_user" {
  type    = string
  default = "userflow_app"
}

variable "database_url" {
  description = "Opcional: URL PostgreSQL externa. Vacía usa Cloud SQL creado por Terraform."
  type        = string
  sensitive   = true
  default     = ""
}

variable "jwt_secret" {
  description = "Clave JWT de al menos 32 caracteres. Se almacena en Secret Manager."
  type        = string
  sensitive   = true
}

variable "notification_service_name" {
  description = "Nombre de la Cloud Run que procesa notificaciones."
  type        = string
  default     = "notification-cloud-run"
}

variable "notification_topic_name" {
  description = "Nombre del tema Pub/Sub."
  type        = string
  default     = "userflow-notifications"
}

variable "notification_subscription_name" {
  description = "Nombre de la suscripción push."
  type        = string
  default     = "userflow-notifications-push"
}

variable "notification_image_tag" {
  description = "Etiqueta de la imagen Docker del servicio de notificaciones."
  type        = string
  default     = "latest"
}

variable "smtp_host" {
  description = "Servidor SMTP utilizado para enviar correos."
  type        = string
  default     = "smtp.gmail.com"
}

variable "smtp_port" {
  description = "Puerto SMTP."
  type        = number
  default     = 587
}

variable "smtp_user" {
  description = "Correo utilizado para enviar notificaciones."
  type        = string
  sensitive   = true
}

variable "smtp_password" {
  description = "Contrasena de aplicacion del correo SMTP."
  type        = string
  sensitive   = true
}