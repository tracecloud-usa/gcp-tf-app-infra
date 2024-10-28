variable "ssl_certificate_map" {
  description = "The SSL certificate map to use for the load balancer"
  type = object({
    name    = string
    project = string
  })
}

variable "https_lb" {
  type = object({
    name_prefix = string
    project     = string
    backends = list(object({
      name        = string
      type        = string
      protocol    = string
      port        = number
      port_name   = string
      timeout_sec = number
      enable_cdn  = bool
      health_check = object({
        request_path = string
        port         = number
      })
      log_config = object({
        enable      = bool
        sample_rate = number
      })
      groups = list(object({
        ig = string
      }))
      iap_config = object({
        enable = bool
      })
    }))
  })
}


variable "url_map" {
  description = "The URL map to use for the load balancer"
  type = object({
    hosts = list(string)
    paths = list(object({
      host    = string
      path    = string
      backend = string
    }))
  })

}
