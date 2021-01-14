variable "edge_count" {}

variable "etcd_count" {}

variable "master_count" {}

variable "node_count" {}

variable "bastion_host" {}

variable "edge_bit" {
  default = 250
}

variable "etcd_bit" {
  default = 50
}

variable "master_bit" {
  default = 100
}

variable "node_bit" {
  default = 200
}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = list
}

variable "private_ips" {
  type = list
}

variable "vpn_interface" {
  default = "wg0"
}

variable "vpn_port" {
  default = "51820"
}

variable "hostnames" {
  type = list
}

variable "overlay_cidr" {
  type = string
}

variable "vpn_iprange" {
  default = "172.17.4.0/24"
}

variable "vpn_ipv6range" {
  default = "fd86:ea04:1115::/64"
}