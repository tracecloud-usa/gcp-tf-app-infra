variable "config" {
  type = object({
    project = string
    region  = string
  })
  default = {
    project = "vpc-edge-prod-01"
    region  = "us-east4"
  }
}

variable "websites" {
  type = list(object({
    domain     = string
    files      = list(string)
    host       = string
    web_server = string
  }))
  default = [{
    host       = "nginx"
    domain     = "test.tracecloud.us"
    web_server = "web-node-01"
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
