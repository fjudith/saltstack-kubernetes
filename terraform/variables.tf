variable "hcloud_location" {
  description = "Hetzner cloud hosting region: Nuremberg (nbg1), Falkenstein (fsn1), Helsinki (hel1)"
  default     = "nbg1"
}

variable "hcloud_token" {
  description = "Hetzner cloud token"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "hcloud_ssh_keys" {
  default = []
}

variable "scaleway_region" {
  description = "Scaleway hosting region: Paris (par1), Amsterdam (ams1)"
  default     = "par1"
}

variable "scaleway_organization" {
  description = "Scaleway access_key"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "scaleway_token" {
  description = "Scaleway secret_key"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "cluster_public_dns" {
  description = "Kubernetes cluster public DNS record"
  default     = "kubernetes.domain.tld"
}

variable "architecture" {
  description = "Operating system image base architecture"
  default     = "x86_64"
}

variable "image" {
  default = "Ubuntu Focal"
}

variable "etcd_type" {
  default = "START1-XS"
}

variable "edge_count" {
  default = 2
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

variable "saltmaster_host" {
  description = "Ip address, Hostname or FQDN of the Salt Master host"
  default     = "salt-master.domain.tld"
}

variable "saltsyndic_host" {
  description = "Ip address, Hostname or FQDN of the Salt Syndic host"
  default     = "salt-master.domain.tld"
}

variable "etcd_bit" {
  description = "VPN starting IP for etcd"
  default     = 50
}

variable "master_bit" {
  description = "VPN starting IP for master"
  default     = 100
}

variable "node_bit" {
  description = "VPN starting IP for node"
  default     = 200
}

variable "edge_bit" {
  description = "VPN starting IP for edge"
  default     = 250
}

variable "overlay_cidr" {
  default = "10.244.0.0/16"
}

variable "vpn_iprange" {
  description = "Wireguard MeshVPN IPv4 subnet CIDR"
  default     = "172.17.4.0/24"
}

variable "vpn_ipv6range" {
  description = "Wireguard MeshVPN IPv6 subnet"
  default     = "fd86:ea04:1115::/64"
}

variable "cloudflare_email" {
  description = "Cloudflare API access e-mail"
  default     = "user@domain.tld"
}

variable "cloudflare_token" {
  description = "Cloudflare API access token"
  default     = "01234567890123456789012345678901234567"
}

variable "ovh_endpoint" {
  description = "OVH API endpoint"
  default = "ovh-eu"
}

variable "ovh_application_key" {
  description = "OVH API application key"
  default = "0123456789abcdef"
}

variable "ovh_application_secret" {
  description = "OVH API secret key"
  default = "0123456789abcdef0123456789abcdef"
}

variable "ovh_consumer_key" {
  description = "OVH API consummer key"
  default = "0123456789abcdef0123456789abcdef"
}

variable "domain" {
  default = "domain.tld"
}

variable "overlay_interface" {
  description = "Kubernetes Pod Network interface"
  default     = "flannel.1"
}

variable "docker_interface" {
  description = "Docker bridge interface"
  default     = "docker0"
}

variable "service_cidr" {
  description = "Kubernetes service ip range"
  default     = "10.96.0.0/12"
}
