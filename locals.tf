locals {
  definitions_path = "${path.module}/definitions"

  instances_yaml = file("${local.definitions_path}/vms.yaml")
  agents_yaml    = file("${local.definitions_path}/agents.yaml")

  datastores = { for k, v in yamldecode(local.agents_yaml).datastores : v.name => v }
  instances  = { for k, v in yamldecode(local.instances_yaml).vms : v.name => v }

  datastore_files = fileset(var.datastore_docs_directory, "*")
}
