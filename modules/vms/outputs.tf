output "public_ip" {
  value = google_compute_address.this[0].address
}
