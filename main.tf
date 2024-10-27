locals {
  definitions_path = "${path.module}/definitions"
  instances_yaml   = file("${local.definitions_path}/vms.yaml")

  instances = { for k, v in yamldecode(local.instances_yaml).vms : v.name => v }
}

module "webservers" {
  source = "./modules/webservers"

  for_each = local.instances

  name               = each.value.name
  project            = each.value.project
  region             = each.value.region
  zone               = each.value.zone
  service_account    = each.value.service_account
  network_interfaces = each.value.nics
  tags               = each.value.tags
  preemptible        = each.value.preemptible
  machine_type       = each.value.machine_type
  image              = each.value.image
  ssh_key            = "ubuntu:${var.ssh_pub_key}"
}


data "google_certificate_manager_certificate_map" "this" {
  name    = "tracecloud-us-cert-map"
  project = "product-app-prod-01"
}

module "gce-lb-https" {
  source  = "terraform-google-modules/lb-http/google"
  version = "11.0.0"

  name              = "test-tracecloud-lb-https"
  project           = "product-app-prod-01"
  create_url_map    = false
  url_map           = google_compute_url_map.this.self_link
  ssl               = true
  certificate_map   = data.google_certificate_manager_certificate_map.this.id
  https_redirect    = true
  firewall_networks = []

  backends = {
    default = {
      protocol    = "HTTP"
      port        = 80
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/"
        port         = 80
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = module.webservers["web-node-1"].instance_group.self_link
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_url_map" "this" {
  name        = "test-tracecloud-url-map"
  description = "a description"

  default_service = module.gce-lb-https.backend_services["default"].self_link

  host_rule {
    hosts        = ["test.tracecloud.us"]
    path_matcher = "test"
  }

  path_matcher {
    name            = "test"
    default_service = module.gce-lb-https.backend_services["default"].self_link
  }

  test {
    service = module.gce-lb-https.backend_services["default"].self_link
    host    = "test.tracecloud.us"
    path    = "/index.html"
  }
}

