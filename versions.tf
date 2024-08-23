terraform {
  required_version = ">=1.6.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=5.10.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">=5.10.0"
    }
  }
  #  cloud {
  #    organization = "tracecloud"
  #    hostname     = "app.terraform.io"
  #
  #    workspaces {
  #      project = "main"
  #      name    = "gcp-tf-prod-infra"
  #    }
  #  }
}

provider "google" {
  project = var.provider_config.project
  region  = var.provider_config.region
}

provider "google-beta" {
  project = var.provider_config.project
  region  = var.provider_config.region
}

