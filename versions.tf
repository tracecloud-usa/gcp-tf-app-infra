terraform {
  required_version = ">=1.6.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.44.2"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.44.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }

  }
  cloud {
    organization = "tracecloud"

    workspaces {
      name = "gcp-tf-app-infra"
    }
  }
}
