output "cloud_run_url" {
  description = "URL directa de Cloud Run."
  value       = google_cloud_run_v2_service.api.uri
}

output "api_gateway_url" {
  description = "URL que debe usar Flutter (agregar /api)."
  value       = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.docker.name
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "uploads_bucket" {
  value = google_storage_bucket.uploads.name
}

output "notification_cloud_run_url" {
  value = google_cloud_run_v2_service.notification.uri
}

output "notification_topic" {
  value = google_pubsub_topic.notifications.name
}
