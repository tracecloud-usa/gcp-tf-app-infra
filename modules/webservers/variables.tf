variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "service_account" {
  type = string
}

variable "network_interfaces" {
  type = list(object({
    network          = string
    subnet           = string
    assign_public_ip = bool
    network_project  = string
  }))
}

variable "zone" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type = list(string)
}

variable "ssh_key" {
  type = string
}

variable "preemptible" {
  type    = bool
  default = false
}

variable "machine_type" {
  type    = string
  default = "n2-standard-2"
}

variable "image" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}
