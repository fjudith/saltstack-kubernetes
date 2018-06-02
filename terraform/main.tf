##################################################
# Scaleway
##################################################
module "provider" {
  source = "./provider/scaleway"

  organization = "${var.scaleway_organization}"
  token        = "${var.scaleway_token}"
  etcd_count   = "${var.etcd_count}"
  etcd_type    = "${var.etcd_type}"
  master_count = "${var.master_count}"
  master_type  = "${var.master_type}"
  node_count   = "${var.node_count}"
  node_type    = "${var.node_type}"
  region       = "${var.scaleway_region}"
}

# module "zerotier" {
#   source = "security/zerotier"

#   count            = "${var.etcd_count + var.master_count + var.node_count + 1}"
#   bastion_host     = "${module.provider.bastion_host}"
#   bit              = "${var.proxyIP}"
#   zerotier_api_key = "${var.zerotier_api_key}"
#   zerotier_cidr    = "${var.zerotier_cidr}"

#   connections = "${module.provider.private_ips}"
# }

module "salt-minion" {
  source = "management/salt-minion"

  count            = "${var.etcd_count + var.master_count + var.node_count + 2}"
  bastion_host     = "${module.provider.bastion_host}"
  salt_master_host = "${var.saltsyndic_host}"
  connections      = "${module.provider.salt_minion}"
}

module "wireguard" {
  source = "security/wireguard"

  count        = "${var.etcd_count + var.master_count + var.node_count + 2}"
  bastion_host = "${module.provider.bastion_host}"
  private_ips  = "${module.provider.private_ips}"
  hostnames    = "${module.provider.hostnames}"
  overlay_cidr = "${var.overlay_cidr}"
  connections  = "${module.provider.private_ips}"
}

# module "firewall" {
#   source = "security/ufw"


#   count        = "${var.etcd_count + var.master_count + var.node_count + 2}"
#   bastion_host = "${scaleway_server.proxy00.0.public_ip}"
#   # vpn_interface        = "${module.wireguard.vpn_interface}"
#   # vpn_port             = "${module.wireguard.vpn_port}"
#   # kubernetes_interface = "${module.kubernetes.overlay_interface}"
#   connections = "${module.provider.private_ips}"
# }

