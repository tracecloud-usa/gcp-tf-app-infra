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
  name    = var.gcs_bucket.name
  project = var.gcs_bucket.project
}

resource "google_storage_bucket_object" "datastore_file" {
  for_each = { for file in local.datastore_files : file => file }

  name   = each.value
  bucket = data.google_storage_bucket.this.name
  source = "${var.datastore_docs_directory}/${each.value}"
}

