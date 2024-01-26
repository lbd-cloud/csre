provider "google" {
  credentials = jsondecode(var.google_credentials)
  project     = var.project_id
  region      = var.region
}

variable "google_credentials" {
  description = "GCP JSON credentials"
  type        = string
  default     = env("GOOGLE_CREDENTIALS")
}
