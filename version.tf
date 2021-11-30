terraform {
  backend "gcs" {
    bucket  = "sidespin-tf"
    prefix  = "terraform/runners"
  }
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.5.0"
    }
    google = {
      source = "hashicorp/google"
      version = "3.88.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.7.0"
    }
  }
  required_version = ">= 1.0.0"
}