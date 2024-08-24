variable "provider_config" {
  type = object({
    project = string
    region  = string
  })
}

variable "websites" {
  type = list(object({
    domain = string
    files  = list(string)
  }))
  default = [{
    domain = "ai.tracecloud.us"
    files = [
      "index.html",
      "styles.css",
      "banner-background.jpg",
      "contact.html",
      "pricing.html",
      "features.html",
    ]
  }]
}


# stored in TFE
variable "ssh_pub_key" {}

