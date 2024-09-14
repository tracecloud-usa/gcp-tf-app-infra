variable "provider_config" {
  type = object({
    project = string
    region  = string
  })
  default = {
    project = "vpc-edge-prod-01"
    region  = "us-east4"
  }
}

# stored in TFE
variable "ssh_pub_key" {}

variable "agent_alias_provider_config" {
  type = object({
    project = string
    region  = string
  })
  default = {
    project = "product-app-prod-01"
    region  = "us-east4"
  }
}
