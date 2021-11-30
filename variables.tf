variable "project_id" {
  description = "The project ID to deploy to"
}

variable "zone_runners" {
  description = "GCP region to deploy resources to"
  default     = "us-central1-a"
}

variable "node_type" {}

variable "gitlab_token" {
  description = "gitlab access token"
  default     = ""
}
variable "gitlab_url" {}
