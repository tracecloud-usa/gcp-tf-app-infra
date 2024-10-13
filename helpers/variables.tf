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
