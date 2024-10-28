# resource "google_compute_backend_bucket" "image_backend" {
#   name        = "image-backend-bucket"
#   description = "images used for links"
#   bucket_name = data.google_storage_bucket.this.name
#   enable_cdn  = false
# }

data "google_certificate_manager_certificate_map" "this" {
  name    = var.ssl_certificate_map["name"]
  project = var.ssl_certificate_map["project"]
}

module "gce-lb-https" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "12.0.0"

  name              = var.https_lb["name_prefix"]
  project           = var.https_lb["project"]
  create_url_map    = false
  url_map           = google_compute_url_map.this.self_link
  ssl               = true
  certificate_map   = data.google_certificate_manager_certificate_map.this.id
  https_redirect    = true
  firewall_networks = []

  backends = {
    for backends in var.https_lb["backends"] : backends.name => {
      protocol    = backends.protocol
      port        = backends.port
      port_name   = backends.port_name
      timeout_sec = coalesce(backends.timeout_sec, 10)
      enable_cdn  = coalesce(backends.enable_cdn, false)

      health_check = backends.health_check != null ? {
        request_path = backends.health_check.request_path
        port         = backends.health_check.port
        } : {
        request_path = "/"
        port         = backends.port
      }

      log_config = backends.log_config != null ? {
        enable      = backends.log_config.enable
        sample_rate = backends.log_config.sample_rate
        } : {
        enable      = true
        sample_rate = 1
      }

      groups = [for group in backends.groups : {
        group = group.ig
      }]

      iap_config = backends.iap_config != null ? backends.iap_config : {
        enable = false
      }
    }
  }
}

resource "google_compute_url_map" "this" {
  name    = "${var.https_lb["name_prefix"]}-url-map"
  project = var.https_lb["project"]

  default_service = module.gce-lb-https.backend_services["default"].self_link

  dynamic "host_rule" {
    for_each = toset(var.url_map["hosts"])

    content {
      hosts        = [host_rule.value]
      path_matcher = replace(host_rule.value, ".", "-")
    }
  }

  dynamic "path_matcher" {
    for_each = toset(var.url_map["hosts"])

    content {
      name            = replace(path_matcher.value, ".", "-")
      default_service = module.gce-lb-https.backend_services["default"].self_link

      dynamic "path_rule" {
        for_each = [for rule in var.url_map["paths"] : rule if replace(rule.host, ".", "-") == path_matcher.value]

        content {
          paths   = [path_rule.value.path]
          service = path_rule.value.backend
        }

      }
    }
  }
}
