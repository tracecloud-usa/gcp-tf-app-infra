provider "google" {
  project = var.provider_config.project
  region  = var.provider_config.region
}

provider "google-beta" {
  project = var.provider_config.project
  region  = var.provider_config.region
}

provider "random" {}

provider "null" {}
