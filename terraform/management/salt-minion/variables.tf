variable "bastion_host" {}

variable "http_proxy_host" {}

variable "http_proxy_port" {}

variable "edge_count" {}

variable "edge_private_ips" {
  type = list
}

variable "etcd_count" {}

variable "etcd_private_ips" {
  type = list
}

variable "master_count" {}

variable "master_private_ips" {
  type = list
}

variable "node_count" {}

variable "node_private_ips" {
  type = list
}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

# variable "connections" {
#   type = list
# }

variable "salt_master_host" {}
