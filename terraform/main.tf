# Scaleway
##################################################
# module "provider" {
#   source = "./provider/scaleway"

#   organization     = "${var.scaleway_organization}"
#   token            = "${var.scaleway_token}"
#   proxy_type       = "${var.proxy_type}"
#   etcd_count       = "${var.etcd_count}"
#   etcd_type        = "${var.etcd_type}"
#   master_count     = "${var.master_count}"
#   master_type      = "${var.master_type}"
#   node_count       = "${var.node_count}"
#   node_type        = "${var.node_type}"
#   node_volume_size = "${var.node_volume_size}"
#   region           = "${var.scaleway_region}"
# }

# Hetzner cloud (hcloud)
##################################################
module "provider" {
  source = "./provider/hcloud"

  token        = "${var.hcloud_token}"
  proxy_type   = "${var.proxy_type}"
  etcd_count   = "${var.etcd_count}"
  etcd_type    = "${var.etcd_type}"
  master_count = "${var.master_count}"
  master_type  = "${var.master_type}"
  node_count   = "${var.node_count}"
  node_type    = "${var.node_type}"
  location     = "${var.hcloud_location}"
  ssh_keys     = "${var.hcloud_ssh_keys}"
}

module "proxy-exception" {
  source = "./security/proxy-exceptions"

  count        = "${var.etcd_count + var.master_count + var.node_count + 2}"
  bastion_host = "${module.provider.bastion_host}"
  vpn_iprange  = "${var.vpn_iprange}"
  overlay_cidr = "${var.overlay_cidr}"
  service_cidr = "${var.service_cidr}"
  connections  = "${module.provider.private_ips}"
}

module "dns" {
  source = "./dns/cloudflare"

  count      = 1
  email      = "${var.cloudflare_email}"
  token      = "${var.cloudflare_token}"
  domain     = "${var.domain}"
  public_ips = "${module.provider.public_ip}"
  hostnames  = "${module.provider.proxy_hostname}"
}

module "wireguard" {
  source = "./security/wireguard"

  count        = "${var.etcd_count + var.master_count + var.node_count + 2}"
  bastion_host = "${module.provider.bastion_host}"
  private_ips  = "${module.provider.private_ips}"
  proxy_count  = "${var.proxy_count}"
  proxy_bit    = "${var.proxy_bit}"
  etcd_count   = "${var.etcd_count}"
  etcd_bit     = "${var.etcd_bit}"
  master_count = "${var.master_count}"
  master_bit   = "${var.master_bit}"
  node_count   = "${var.node_count}"
  node_bit     = "${var.node_bit}"
  hostnames    = "${module.provider.hostnames}"
  overlay_cidr = "${var.overlay_cidr}"
  vpn_iprange  = "${var.vpn_iprange}"
  connections  = "${module.provider.private_ips}"
}

module "salt-master" {
  source = "./management/salt-master"

  count            = 1
  bastion_host     = "${module.provider.bastion_host}"
  salt_master_host = "${var.saltmaster_host}"
  connections      = "${module.provider.salt_syndic}"
}

# module "salt-minion" {
#   source = "./management/salt-minion"

#   bastion_host       = "${module.provider.bastion_host}"
#   salt_master_host   = "${module.wireguard.proxy_vpn_ips[0]}"
#   http_proxy_host    = "${module.wireguard.proxy_vpn_ips[0]}"
#   http_proxy_port    = 3128
#   proxy_count        = "${var.proxy_count}"
#   proxy_private_ips  = "${module.wireguard.proxy_vpn_ips}"
#   etcd_count         = "${var.etcd_count}"
#   etcd_private_ips   = "${module.wireguard.etcd_vpn_ips}"
#   master_count       = "${var.master_count}"
#   master_private_ips = "${module.wireguard.master_vpn_ips}"
#   node_count         = "${var.node_count}"
#   node_private_ips   = "${module.wireguard.node_vpn_ips}"
# }

# module "firewall-proxy" {
#   source = "./security/ufw/proxy"

#   count                = "${var.proxy_count}"
#   bastion_host         = "${module.provider.bastion_host}"
#   private_interface    = "${module.provider.private_network_interface}"
#   vpn_interface        = "${module.wireguard.vpn_interface}"
#   vpn_port             = "${module.wireguard.vpn_port}"
#   docker_interface     = "${var.docker_interface}"
#   kubernetes_interface = "${var.overlay_interface}"
#   overlay_cidr         = "${var.overlay_cidr}"
#   connections          = "${module.provider.proxy_private_ips}"
# }

# module "firewall-etcd" {
#   source = "./security/ufw/etcd"

#   count             = "${var.etcd_count}"
#   bastion_host      = "${module.provider.bastion_host}"
#   private_interface = "${module.provider.private_network_interface}"
#   vpn_interface     = "${module.wireguard.vpn_interface}"
#   vpn_port          = "${module.wireguard.vpn_port}"
#   docker_interface  = "${var.docker_interface}"
#   overlay_cidr      = "${var.overlay_cidr}"
#   connections       = "${module.provider.etcd_private_ips}"
# }

# module "firewall-master" {
#   source = "./security/ufw/master"

#   count                = "${var.master_count}"
#   bastion_host         = "${module.provider.bastion_host}"
#   private_interface    = "${module.provider.private_network_interface}"
#   vpn_interface        = "${module.wireguard.vpn_interface}"
#   vpn_port             = "${module.wireguard.vpn_port}"
#   docker_interface     = "${var.docker_interface}"
#   kubernetes_interface = "${var.overlay_interface}"
#   overlay_cidr         = "${var.overlay_cidr}"
#   connections          = "${module.provider.master_private_ips}"
# }

# module "firewall-node" {
#   source = "./security/ufw/node"

#   count                = "${var.node_count}"
#   bastion_host         = "${module.provider.bastion_host}"
#   private_interface    = "${module.provider.private_network_interface}"
#   vpn_interface        = "${module.wireguard.vpn_interface}"
#   vpn_port             = "${module.wireguard.vpn_port}"
#   docker_interface     = "${var.docker_interface}"
#   kubernetes_interface = "${var.overlay_interface}"
#   overlay_cidr         = "${var.overlay_cidr}"
#   connections          = "${module.provider.node_private_ips}"
# }

module "encryption" {
  source = "./encryption/cfssl"

  bastion_host       = "${module.provider.bastion_host}"
  proxy_count        = "${var.proxy_count}"
  proxy_private_ips  = "${module.wireguard.proxy_vpn_ips}"
  proxy_hostnames    = "${module.provider.proxy_hostnames}"
  etcd_count         = "${var.etcd_count}"
  etcd_private_ips   = "${module.wireguard.etcd_vpn_ips}"
  etcd_hostnames     = "${module.provider.etcd_hostnames}"
  master_count       = "${var.master_count}"
  master_private_ips = "${module.wireguard.master_vpn_ips}"
  master_hostnames   = "${module.provider.master_hostnames}"
  node_count         = "${var.node_count}"
  node_private_ips   = "${module.wireguard.node_vpn_ips}"
  node_hostnames     = "${module.provider.node_hostnames}"
  cluster_public_dns = "${var.cluster_public_dns}"
  domain             = "${var.domain}"
}

# module "default-route-vpn" {
#   source = "./routing"

#   count         = "${var.etcd_count + var.master_count + var.node_count + 1}"
#   bastion_host  = "${module.provider.bastion_host}"
#   vpn_interface = "${module.wireguard.vpn_interface}"
#   gateway       = "${element(module.wireguard.gateway_vpn_ips,0)}"
#   connections   = "${concat(list(module.wireguard.proxy_vpn_ips[1]), module.wireguard.etcd_vpn_ips, module.wireguard.master_vpn_ips, module.wireguard.node_vpn_ips)}"
# }

output "hostnames" {
  value = "${module.provider.hostnames}"
}

output "proxy_hostnames" {
  value = "${module.provider.proxy_hostnames}"
}

output "private_ips" {
  value = "${module.provider.private_ips}"
}

output "vpn_ips" {
  value = "${module.wireguard.vpn_ips}"
}

output "public_ips" {
  value = "${module.provider.public_ips}"
}
