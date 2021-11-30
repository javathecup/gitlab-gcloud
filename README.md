# gitlab-kubernetes-template
   
## Create a cloud storage bucket and change the variable in "main.tf" 
cloud storage will be used as terraform backend

```
  backend "gcs" {
    bucket  = "" # backet name
    prefix  = "terraform/state"
  }
```
## change vars in "cloudbuild.yaml"

```
    - 'TF_VAR_project_id='  # enter project id
    - 'TF_VAR_domain='  # enter domain -> gitlab will be accecible via gitlab.domain
    - 'TF_VAR_token='  # gitlab runner token
```

#### maain.tf explanation
Create a GKE cluster 

```
resource "google_container_cluster" "runners" {
  name     = "runners"
  location = var.region
  initial_node_count       = 1
  node_config {
    machine_type = "e2-medium"
    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  workload_identity_config {
    #identity_namespace = "${data.google_project.project.project_id}.svc.id.goog"
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
  depends_on = [
    google_project_service.gke,
  ]
}
```

create a namespace for runners
```
resource "kubernetes_namespace" "runner" {
  metadata {
    name = "deployer"
  }
}
```
create kubernetes service account
```
resource "kubernetes_service_account" "runner-sa" {
  metadata {
    name      = "deployer"
    namespace = kubernetes_namespace.runner.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.sa.email
    }
  }
  depends_on = [
    google_container_cluster.runners,
  ]
}
```
create GCP service account
```
resource "google_service_account" "sa" {
  account_id   = "gke-deployer"
  display_name = "deployer"
}
```
Bind the GCP service account to workload identity
```
resource "google_service_account_iam_member" "main" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.runner.metadata[0].name}/${kubernetes_service_account.runner-sa.metadata[0].name}]"
}
```
Add a role to the service accountr used by the runner
```
resource "google_project_iam_member" "role" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.sa.email}"
}
```
deploy runners using helm chart
```
resource "helm_release" "runner" {
  name       = "runners"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-runner"

  values = [
    "${file("./modules/gitlab-runners/helm_values/runners.yaml")}"
  ]
  set {
    name  = "gitlabUrl"
    value = var.domain
  }
  set {
    name  = "runnerRegistrationToken"
    value =  var.token
  }
  set {
    name  = "runners.namespace"
    value =  kubernetes_namespace.runner.metadata[0].name
  }
  set {
    name  = "runners.serviceAccountName"
    value =  kubernetes_service_account.runner-sa.metadata[0].name
  }
  depends_on = [
    kubernetes_service_account.runner-sa,
  ]
}
```
### Cloud build service account role
- Security Admin
- Service Account Admin
