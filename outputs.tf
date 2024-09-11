output "webserver_public_ip" {
  value = { for k, v in module.vms : k => v.public_ip }
}
