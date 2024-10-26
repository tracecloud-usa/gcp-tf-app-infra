output "webserver_public_ip" {
  value = { for k, v in module.webservers : k => v.public_ip }
}
