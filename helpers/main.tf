resource "local_file" "nginx_config" {
  for_each = { for k, v in var.websites : k => v }

  filename = "../playbooks/sites/${each.value.domain}.conf"
  content = templatefile("${path.module}/templates/${each.value.host}.conf.tpl", {
    domain = each.value.domain
  })
}

resource "local_file" "nginx_ansible_vars" {
  for_each = { for k, v in var.websites : k => v }

  filename = "../playbooks/host_vars/${each.value.host}.yaml"
  content = templatefile("${path.module}/templates/host_vars.tpl", {
    domain        = each.value.domain
    public_ip     = data.tfe_outputs.this.nonsensitive_values["webserver_public_ip"][each.value.web_server]
    website_files = each.value.files
    host          = each.value.host
  })
}

data "tfe_outputs" "this" {
  organization = "tracecloud"
  workspace    = "gcp-tf-prod-infra"
}
