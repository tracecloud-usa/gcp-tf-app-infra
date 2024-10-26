locals {
  webserver_website_config = yamldecode(file("../definitions/websites.yaml"))
  websites                 = { for k, v in local.webserver_website_config.websites : k => v }

  definitions_path = "../definitions"

  instances_yaml = file("${local.definitions_path}/vms.yaml")
  instances      = { for k, v in yamldecode(local.instances_yaml).vms : v.name => v }
}

resource "local_file" "nginx_config" {
  for_each = local.websites

  filename = "../playbooks/sites/${each.value.domain}.conf"
  content = templatefile("${path.module}/templates/${each.value.host}.conf.tpl", {
    domain = each.value.domain
  })
}

resource "local_file" "nginx_ansible_vars" {
  for_each = local.websites

  filename = "../playbooks/host_vars/${each.value.host}.yaml"
  content = templatefile("${path.module}/templates/host_vars.tpl", {
    domain        = each.value.domain
    public_ip     = data.tfe_outputs.this.nonsensitive_values["webserver_public_ip"][each.value.web_server]
    website_files = each.value.files
    host          = each.value.host
  })
}

resource "local_file" "startup_script" {
  for_each = local.instances

  filename = "./scripts/startup-script.sh"
  content = templatefile("${path.module}/templates/startup-script.tpl", {
    username        = each.value.startup_script.vars["username"]
    ssh_pubkey_path = each.value.startup_script.vars["ssh_pubkey_path"]
  })
}


data "tfe_outputs" "this" {
  organization = "tracecloud"
  workspace    = "gcp-tf-app-infra"
}
