module "gce-lb-https" {
  source            = "github.com/terraform-google-modules/terraform-google-lb-http.git?ref=v12.0.0"
  name              = "test-tracecloud-lb-https"
  project           = "product-app-prod-01"
  create_url_map    = true
  ssl               = true
  certificate_map   = data.google_certificate_manager_certificate_map.this.id
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

data "google_certificate_manager_certificate_map" "this" {
  name    = "tracecloud-us-cert-map"
  project = "product-app-prod-01"
}
