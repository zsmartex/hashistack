variable "hcloud_token" {
  type      = string
  sensitive = false
}

variable "ssh_public_key_file" {
  type = string
}

variable "separate_consul_servers" {
  type = bool
  default = false
}

variable "server_count" {
  type = number
}

variable "vault_count" {
  type = number
}

variable "client_count" {
  type =  number
}

variable "multi_instance_observability" {
  type = bool
}

variable "server_location" {
  type = string
}

variable "network_location" {
  type = string
}

variable "load_balancer_location" {
  type = string
}

variable "server_instance_type" {
  type = string
}

variable "client_instance_type" {
  type = string
}

variable "observability_instance_type" {
  type = string
}

variable "load_balancer_type" {
  type    = string
}

variable "consul_volume_size" {
  type = number
}

variable "vault_volume_size" {
  type = number
}

variable "client_volumes" {
  type = list(object({
    name      = string
    client_id = number
    path      = string
    size      = number
    owner     = optional(string)
    group     = optional(string)
  }))
}

variable "base_server_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "firewall_name" {
  type = string
}