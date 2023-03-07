variable "consul_address" {}
variable "datacenter" {}
variable "token" {}
variable "ca_file" {
  default = null
}

variable "cert_file" {
  type = string
  default = null
}

variable "key_file" {
  type = string
  default = null
}
