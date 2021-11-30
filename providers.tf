provider "google" {}

provider "gitlab" {
  token = var.gitlab_token
  base_url = "https://${var.gitlab_url}/api/v4/"
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.runners.endpoint
    client_certificate     = base64decode(google_container_cluster.runners.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster.runners.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.runners.master_auth.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = google_container_cluster.runners.endpoint
  client_certificate     = base64decode(google_container_cluster.runners.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster.runners.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.runners.master_auth.0.cluster_ca_certificate)
}
