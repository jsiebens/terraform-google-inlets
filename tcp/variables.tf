variable name {
  type    = string
  default = null
}

variable network {
  type    = string
  default = "default"
}

variable subnetwork {
  type    = string
  default = null
}

variable zone {
  type = string
}

variable machine_type {
  type    = string
  default = "f1-micro"
}

variable ssh_port {
  type    = number
  default = 22
}

variable control_source_ranges {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable data_source_ranges {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable data_ports {
  type    = list(string)
  default = ["8080"]
}

variable auto_tls_san {
  type    = string
  default = null
}
