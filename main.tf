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
    network    = data.google_compute_network.this[each.value.network].self_link
    subnetwork = data.google_compute_subnetwork.this[each.value.subnet].self_link
  }

  service_account {
    email  = data.google_service_account.this[each.value.service_account].email
    scopes = ["cloud-platform"]
  }
}


data "google_compute_subnetwork" "this" {
  for_each = { for k, v in var.instances : v.subnet => v }

  name    = each.value.subnet
  project = each.value.network_project
  region  = data.google_client_config.this.region
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

data "google_client_config" "this" {}
