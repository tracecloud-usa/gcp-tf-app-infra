data "google_compute_subnetwork" "this" {
  for_each = { for index, nic in var.network_interfaces : index => nic }

  name    = each.value.subnet
  project = each.value.network_project
  region  = var.region
}

data "google_compute_network" "this" {
  for_each = { for index, nic in var.network_interfaces : index => nic }

  name    = each.value.network
  project = each.value.network_project
}

data "google_service_account" "this" {
  account_id = var.service_account
  project    = var.project
}


