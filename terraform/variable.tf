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
  default = "Ubuntu Xenial"
}

variable "etcd_type" {
  default = "START1-XS"
}

variable "proxy_count" {
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

variable "proxy_type" {
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

variable "web_proxy_host" {
  description = "Ip address, Hostname or FQDN of Web Proxy"
  default     = "web-proxy.domain.tld"
}

variable "IFACE" {
  description = "Network "
  default     = "web-proxy.domain.tld"
}

variable "etcd_bit" {
  description = "Zerotier etcd starting IP"
  default     = 50
}

variable "master_bit" {
  description = "Zerotier master starting IP"
  default     = 100
}

variable "node_bit" {
  description = "Zerotier node starting IP"
  default     = 200
}

variable "proxy_bit" {
  description = "Zerotier proxy starting IP"
  default     = 250
}

variable "zerotier_api_key" {
  description = "Zerotier MeshVPN API key"
  default     = "01234567890123456789012345678901"
}

variable "zerotier_cidr" {
  description = "Zerotier MeshVPN subnet CIDR"
  default     = "172.16.4.0/24"
}

variable "overlay_cidr" {
  default = "10.2.0.0/16"
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
  default     = "10.3.0.0/24"
}
