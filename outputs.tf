output "webserver_public_ip" {
  value = { for k, v in module.webservers : k => v.public_ip }
}

output "lb_vips" {
  value = { for name, lb in module.application_load_balancer : name => lb.external_ip }
}
