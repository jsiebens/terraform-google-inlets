output "token" {
  value = random_string.token.result
}

output "address" {
  value = google_compute_address.inlets.address
}