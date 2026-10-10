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
