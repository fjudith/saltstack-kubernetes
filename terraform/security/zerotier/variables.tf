variable "count" {}

variable "bit" {}

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

variable "zerotier_api_key" {
  description = "Zerotier MeshVPN API key"
  default     = "01234567890123456789012345678901"
}

variable "zerotier_cidr" {
  description = "Zerotier MeshVPN subnet CIDR"
  default     = "172.16.4.0/24"
}