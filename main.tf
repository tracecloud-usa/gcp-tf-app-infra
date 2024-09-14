locals {
  definitions_path = "${path.module}/definitions"
  instances_yaml   = file("${local.definitions_path}/vms.yaml")
  agents_yaml      = file("${local.definitions_path}/agents.yaml")
  datastores       = { for k, v in yamldecode(local.agents_yaml).datastores : v.name => v }
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

module "ai_agent_builder" {
  source = "./modules/agent"

  providers = {
    google = google.ai_agent
  }

  datastores = { for k, v in yamldecode(local.agents_yaml).datastores : v.name => v }
}

data "google_storage_bucket" "this" {
  name    = "ai-test-docs-bucket"
  project = "product-app-prod-01"
}
