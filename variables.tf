variable "provider_config" {
  type = object({
    project = string
    region  = string
  })
}
