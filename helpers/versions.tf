terraform {
  required_version = ">=1.6.6"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.58.1"
    }
  }
}
