resource "google_compute_instance" "this" {
  for_each = { for k, v in var.instances : k => v }

  name         = each.value.name
  project      = each.value.app_project
  machine_type = "n2-standard-2"
  zone         = "us-east4-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = data.google_compute_network.this[each.value.network].self_link
  }

  service_account {
    email  = data.google_service_account.this[each.value.service_account].email
    scopes = ["cloud-platform"]
  }
}

variable "instances" {
  type = list(object({
    name            = string
    app_project     = string
    service_account = string
    network         = string
    network_project = string
  }))
  default = [{
    name            = "test-web-server"
    app_project     = "product-app-prod-01"
    service_account = "nginx-web-admin"
    network         = "vpc-edge-untrusted"
    network_project = "vpc-edge-prod-01"
  }]
}

data "google_compute_network" "this" {
  for_each = { for k, v in var.instances : v.network => v }

  name    = each.value.network
  project = each.value.network_project
}

data "google_service_account" "this" {
  for_each = { for k, v in var.instances : v.service_account => v }

  account_id = each.value.service_account
  project    = each.value.app_project
}

data "google_compute_zones" "this" {}
