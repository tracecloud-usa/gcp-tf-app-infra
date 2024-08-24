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

variable "websites" {
  type = list(object({
    domain = string
    files  = list(string)
  }))
  default = [{
    domain = "ai.tracecloud.us"
    files = [
      "index.html",
      "styles.css",
      "logo.png",
      "hero-background.jpg",
    ]
  }]
}

resource "local_file" "nginx_config" {
  for_each = { for k, v in var.websites : k => v }

  filename = "${path.module}/playbooks/sites/${each.value.domain}.conf"
  content = templatefile("${path.module}/templates/nginx.conf.tpl", {
    domain = each.value.domain
  })
}

