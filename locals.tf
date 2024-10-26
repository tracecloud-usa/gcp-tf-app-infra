locals {
  definitions_path = "${path.module}/definitions"

  instances_yaml = file("${local.definitions_path}/vms.yaml")

  instances = { for k, v in yamldecode(local.instances_yaml).vms : v.name => v }

  datastore_files = fileset(var.datastore_docs_directory, "*")
}
