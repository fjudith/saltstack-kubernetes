variable "location" {
  description = "Hetzner cloud hosting region: Nuremberg (nbg1), Falkenstein (fsn1), Helsinki (hel1)"
  default     = "nbg1"
}

variable "token" {
  description = "Hetzner cloud token"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "ssh_keys" {
  type = "list"
}

variable "image" {
  type    = "string"
  default = "ubuntu-18.04"
}

variable "apt_packages" {
  type    = "list"
  default = []
}

variable "etcd_type" {
  type    = "string"
  default = "cx11"
}

variable "etcd_count" {
  default = 3
}

variable "master_type" {
  default = "cx11"
}

variable "master_count" {
  default = 3
}

variable "node_type" {
  default = "cx41"
}

variable "node_count" {
  default = 3
}

variable "proxy_type" {
  default = "cx11"
}

variable "ssh_user" {
  description = "Username to connect the server"
  default     = "root"
}

variable "ssh_public_key" {
  description = "Path to your public SSH key path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  description = "Path to your private SSH key path"
  default     = "~/.ssh/id_rsa.insecure"
}

variable "ssh_bastion_host" {
  description = "Ip address, Hostname or FQDN of the SSH bastion hsot"
  default     = "ssh-bastion.domain.tld"
}

provider "hcloud" {
  token = "${var.token}"
}

variable "vpn_interface" {
  default = "wg0"
}

variable "vpn_iprange" {
  description = "Wireguard MeshVPN IPv4 subnet CIDR"
  default     = "172.17.4.0/24"
}

variable "vpn_ipv6range" {
  description = "Wireguard MeshVPN IPv6 subnet"
  default     = "fd86:ea04:1115::/64"
}

variable "vpn_port" {
  default = "51820"
}