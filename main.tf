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
  ssh_key            = "ubuntu:${var.ssh_pub_key}"
}


data "google_storage_bucket" "this" {
  name    = var.gcs_bucket.name
  project = var.gcs_bucket.project
}

resource "google_storage_bucket_object" "datastore_file" {
  for_each = { for file in local.datastore_files : file => file }

  name   = each.value
  bucket = data.google_storage_bucket.this.name
  source = "${var.datastore_docs_directory}/${each.value}"
}

data "google_certificate_manager_certificate_map" "this" {
  name    = "tracecloud-us-cert-map"
  project = "product-app-prod-01"
}

module "gce-lb-https" {
  # source            = "github.com/terraform-google-modules/terraform-google-lb-http.git?ref=v12.0.0"
  source  = "terraform-google-modules/lb-http/google"
  version = "11.0.0"

  name              = "test-tracecloud-lb-https"
  project           = "product-app-prod-01"
  create_url_map    = true
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
