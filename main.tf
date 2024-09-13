locals {
  definitions_path = "${path.module}/definitions"
  instances_yaml   = file("${local.definitions_path}/vms/vms.yaml")
  instances        = { for k, v in yamldecode(local.instances_yaml).vms : v.name => v }
}

module "vms" {
  source = "./modules/vms"

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
  name    = "ai-test-docs-bucket"
  project = "product-app-prod-01"
}

