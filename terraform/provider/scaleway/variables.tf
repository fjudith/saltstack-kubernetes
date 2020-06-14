variable "region" {
  description = "Scaleway hosting region: Paris (par1), Amsterdam (ams1)"
  default     = "par1"
}

variable "organization" {
  description = "Scaleway access_key"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "token" {
  description = "Scaleway secret_key"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "architecture" {
  description = "Operating system image base architecture"
  default     = "x86_64"
}

variable "image" {
  default = "Ubuntu Bionic"
}

variable "apt_packages" {
  type    = "list"
  default = []
}

variable "etcd_type" {
  default = "START1-XS"
}

variable "etcd_count" {
  default = 3
}

variable "master_type" {
  default = "START1-S"
}

variable "master_count" {
  default = 3
}

variable "node_type" {
  default = "START1-M"
}

variable "node_volume_size" {
  default = 50
}

variable "node_count" {
  default = 3
}

variable "edge_type" {
  default = "START1-S"
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