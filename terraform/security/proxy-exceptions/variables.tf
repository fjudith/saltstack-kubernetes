variable "count" {}

variable "vpn_iprange" {}

variable "overlay_cidr" {}

variable "service_cidr" {}

variable "bastion_host" {}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = "list"
}
