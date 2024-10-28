locals {
  definitions_path = "${path.module}/definitions"
  instances_yaml   = file("${local.definitions_path}/vms.yaml")

  instances = { for k, v in yamldecode(local.instances_yaml).vms : v.name => v }

  website_files_dir = "./website_files"

  website_files = fileset(local.website_files_dir, "*")
}

data "google_storage_bucket" "this" {
  name    = "tracecloud-website-files-01"
  project = "product-app-prod-01"
}

resource "google_storage_bucket_object" "this" {
  for_each = { for file in local.website_files : file => file }

  name   = each.value
  bucket = data.google_storage_bucket.this.name
  source = "${local.website_files_dir}/${each.value}"
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


locals {
  load_balancers_yaml = file("${local.definitions_path}/lbs.yaml")
  load_balancers      = { for k, v in yamldecode(local.load_balancers_yaml).lbs : v.name_prefix => v }
}

module "application_load_balancer" {
  source = "./modules/load_balancer"

  for_each = local.load_balancers

  ssl_certificate_map = {
    name    = each.value.ssl_cert_map.name
    project = each.value.ssl_cert_map.project
  }
  url_map = {
    hosts = distinct([for rule in each.value.url_map : rule.host])
    paths = [
      for rule in each.value.url_map : {
        host    = rule.host
        path    = rule.path
        backend = rule.backend
      }
    ]
  }
  https_lb = {
    name_prefix = each.value.name_prefix
    project     = each.value.project
    backends = [
      for backend in each.value.backends : {
        name        = backend.name
        type        = backend.type
        protocol    = backend.protocol
        port        = backend.port
        port_name   = backend.port_name
        timeout_sec = backend.timeout_sec
        enable_cdn  = backend.enable_cdn
        health_check = {
          request_path = backend.health_check.request_path
          port         = backend.health_check.port
        }
        log_config = {
          enable      = backend.log_config.enable
          sample_rate = backend.log_config.sample_rate
        }
        groups = [
          for group in backend.groups : {
            ig = module.webservers[group.ig].instance_group["self_link"]
          }
        ]
        iap_config = {
          enable = backend.iap_config.enable
        }
      }
    ]
  }
}
