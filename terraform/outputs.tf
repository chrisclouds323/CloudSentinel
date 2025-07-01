output "function_name" {
  value = google_cloudfunctions_function.detector_function.name
}

output "pubsub_topic" {
  value = google_pubsub_topic.alerts.name
}

output "log_sink" {
  value = google_logging_project_sink.threat_sink.name
}
