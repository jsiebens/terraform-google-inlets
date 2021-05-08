locals {
  name = var.name != null && var.name != "" ? var.name : format("inlets-%s", random_string.id.result)

  auto_tls_san = var.auto_tls_san != null ? var.auto_tls_san : google_compute_address.inlets.address

  service_file   = templatefile("${path.module}/templates/inlets.service", { auto_tls_san = local.auto_tls_san })
  startup_script = templatefile("${path.module}/templates/startup.sh", { token = random_string.token.result, service_file = local.service_file, ssh_port = var.ssh_port })
}

resource "random_string" "token" {
  length  = 32
  special = false
}

resource "random_string" "id" {
  length  = 6
  upper   = false
  special = false
}

resource "google_compute_address" "inlets" {
  name = local.name
}

resource "google_service_account" "inlets" {
  account_id = local.name
}

resource "google_project_iam_member" "inlets-log-writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.inlets.email}"
}


resource "google_compute_firewall" "inlets-firewall-control" {
  name    = format("%s-allow-control", local.name)
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["8123"]
  }
  source_ranges           = var.control_source_ranges
  target_service_accounts = [google_service_account.inlets.email]
}

resource "google_compute_firewall" "inlets-firewall-data" {
  name    = format("%s-allow-data", local.name)
  network = var.network
  allow {
    protocol = "tcp"
    ports    = var.data_ports
  }
  source_ranges           = var.data_source_ranges
  target_service_accounts = [google_service_account.inlets.email]
}

resource "google_compute_instance" "inlets" {
  name         = local.name
  zone         = var.zone
  machine_type = var.machine_type

  metadata_startup_script = local.startup_script

  metadata = {
    block-project-ssh-keys = "TRUE"
    enable-oslogin         = "TRUE"
  }

  boot_disk {
    initialize_params {
      size  = 50
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {
      nat_ip = google_compute_address.inlets.address
    }
  }

  tags = [local.name]

  shielded_instance_config {
    enable_secure_boot = true
  }

  service_account {
    email = google_service_account.inlets.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

}