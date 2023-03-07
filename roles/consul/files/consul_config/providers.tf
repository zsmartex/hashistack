terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "2.17.0"
    }
  }
}

provider "consul" {
  address    = var.consul_address
  datacenter = var.datacenter
  token      = var.token
  scheme     = "https"
  ca_file    = var.ca_file
  cert_file  = var.cert_file
  key_file   = var.key_file
}
