resource "google_compute_instance" "this" {
  name    = var.name
  project = var.project

  machine_type = "n2-standard-2"
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  metadata = {
    ssh-keys = var.ssh_key
  }

  dynamic "scheduling" {
    for_each = var.preemptible ? [1] : []

    content {
      automatic_restart           = false
      on_host_maintenance         = "TERMINATE"
      preemptible                 = true
      provisioning_model          = "SPOT"
      instance_termination_action = "STOP"
    }
  }

  dynamic "network_interface" {
    for_each = { for k, v in var.network_interfaces : k => v }

    content {
      network    = data.google_compute_network.this[network_interface.key].self_link
      subnetwork = data.google_compute_subnetwork.this[network_interface.key].self_link

      dynamic "access_config" {
        for_each = network_interface.value.assign_public_ip ? [1] : []

        content {
          nat_ip = google_compute_address.this[network_interface.key].address
        }
      }
    }
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  service_account {
    email  = data.google_service_account.this.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_address" "this" {
  for_each = { for k, v in var.network_interfaces : k => v if v.assign_public_ip == true }

  name    = "${var.name}-nat-ip"
  region  = var.region
  project = var.project
}

resource "google_compute_instance_group" "this" {
  name      = "${var.name}-lb-ig"
  project   = google_compute_instance.this.project
  zone      = google_compute_instance.this.zone
  network   = google_compute_instance.this.network_interface[0].network
  instances = [google_compute_instance.this.self_link]
  named_port {
    name = "http"
    port = 80
  }
}
