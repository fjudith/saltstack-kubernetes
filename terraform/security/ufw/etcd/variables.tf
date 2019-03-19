variable "count" {}

variable "bastion_host" {}
variable "overlay_cidr" {}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = "list"
}

variable "private_interface" {
  type = "string"
}

variable "docker_interface" {
  type = "string"
}

variable "vpn_interface" {
  type = "string"
}

variable "vpn_port" {
  type = "string"
}