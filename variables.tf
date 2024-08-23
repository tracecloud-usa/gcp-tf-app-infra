variable "provider_config" {
  type = object({
    project = string
    region  = string
  })
}

variable "instances" {
  type = list(object({
    name            = string
    app_project     = string
    service_account = string
    network         = string
    network_project = string
    subnet          = string
  }))
  default = []
  /*   default = [
    {
      name            = "test-web-server"
      app_project     = "product-app-prod-01"
      service_account = "nginx-web-admin"
      network         = "vpc-edge-untrusted"
      network_project = "vpc-edge-prod-01"
      subnet          = "edge-untrusted-subnet-01"
    },
  ] */
}
