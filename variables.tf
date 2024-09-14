variable "provider_config" {
  type = object({
    project = string
    region  = string
  })
}

# stored in TFE
variable "ssh_pub_key" {}

variable "agent_alias_provider_config" {
  type = object({
    project = string
    region  = string
  })
}

variable "datastore_docs_directory" {
  type = string
}

variable "gcs_bucket" {
  type = object({
    name    = string
    project = string
  })
}
