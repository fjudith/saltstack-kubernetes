variable route_count {}

variable gateway {}

variable "vpn_interface" {
  default = "wg0"
}

variable "bastion_host" {}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = list
}