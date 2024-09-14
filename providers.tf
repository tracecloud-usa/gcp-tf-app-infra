provider "google" {
  project = var.provider_config.project
  region  = var.provider_config.region
}

provider "google" {
  alias   = "ai_agent"
  project = var.agent_alias_provider_config.project
  region  = var.agent_alias_provider_config.region
}

provider "google-beta" {
  project = var.provider_config.project
  region  = var.provider_config.region
}

provider "random" {}
