locals {
  definitions_path    = "${path.module}/definitions"
  instances_yaml      = file("${local.definitions_path}/vms.yaml")
  load_balancers_yaml = file("${local.definitions_path}/lbs.yaml")
  website_files_yaml  = file("${local.definitions_path}/files.yaml")
  website_files_dir   = "./website_files"

  # Decoded YAML definitions
  instances      = { for v in yamldecode(local.instances_yaml).vms : v.name => v }
  load_balancers = { for v in yamldecode(local.load_balancers_yaml).lbs : v.name_prefix => v }

  # File list for website files
  website_files = { for file in yamldecode(local.website_files_yaml).files : file.name => file }
}

data "google_storage_bucket" "website_bucket" {
  for_each = local.website_files

  name    = each.value["bucket_name"]
  project = each.value["bucket_project"]
}

resource "google_storage_bucket_object" "website_files" {
  for_each = local.website_files

  name    = each.value["name"]
  bucket  = data.google_storage_bucket.website_bucket[each.key].name
  source  = !each.value["empty"] ? "${local.website_files_dir}/${each.value["name"]}" : null
  content = each.value["empty"] ? " " : null
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

  backend_buckets = [for backend in each.value.backends : {
    name        = backend.name
    bucket_name = backend.bucket
    enable_cdn  = backend.enable_cdn
    description = try(backend.description, null)
  } if backend.type == "storage_bucket"]

  https_lb = {
    name_prefix = each.value.name_prefix
    project     = each.value.project
    backends = [
      for backend in each.value.backends : {
        name         = backend.name
        protocol     = backend.protocol
        port         = backend.port
        port_name    = backend.port_name
        timeout_sec  = try(backend.timeout_sec, null)
        enable_cdn   = try(backend.enable_cdn, null)
        health_check = try(backend.health_check, null)
        log_config   = try(backend.log_config, null)

        groups = [
          for group in backend.groups : {
            ig = module.webservers[group.ig].instance_group["self_link"]
          }
        ]

        iap_config = try(backend.iap_config, null)
      } if backend.type == "instance_group"
    ]
  }
}
