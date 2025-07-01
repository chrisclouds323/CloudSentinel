resource "google_pubsub_topic" "alerts" {
  name = "cloudshield-alerts-topic"
}

resource "google_storage_bucket" "function_source" {
  name           = "${var.project_id}-cloudshield-function"
  location       = var.region
  force_destroy  = true
}

resource "google_logging_project_sink" "threat_sink" {
  name        = "cloudshield-threat-sink"
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/${google_pubsub_topic.alerts.name}"
  filter      = var.log_filter

  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "sink_writer" {
  topic  = google_pubsub_topic.alerts.name
  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.threat_sink.writer_identity
}

resource "google_cloudfunctions_function" "detector_function" {
  name        = "cloudshield-detector"
  runtime     = "python310"
  entry_point = "main"
  region      = var.region

  source_archive_bucket = google_storage_bucket.function_source.name
  source_archive_object = "function.zip"

  # Environment variable removed — webhook is now hardcoded in main.py

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.alerts.id
  }
}

resource "google_project_iam_member" "function_logging" {
  project = var.project_id
  role    = "roles/logging.viewer"
  member  = "serviceAccount:${google_cloudfunctions_function.detector_function.service_account_email}"
}
