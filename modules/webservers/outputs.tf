output "public_ip" {
  value = google_compute_address.this[0].address
}

output "instance" {
  value = google_compute_instance.this
}

output "instance_group" {
  value = google_compute_instance_group.this
}
