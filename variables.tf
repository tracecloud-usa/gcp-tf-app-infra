variable "provider_config" {
  type = object({
    project = string
    region  = string
  })
}

# stored in TFE
variable "ssh_pub_key" {}

