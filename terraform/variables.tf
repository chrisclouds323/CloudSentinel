variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  default     = "us-central1"
}

variable "log_filter" {
  description = "Log filter for suspicious activity"
  default     = "protoPayload.methodName=\"SetIamPolicy\" OR protoPayload.methodName=\"google.iam.admin.v1.CreateServiceAccountKey\""
}
