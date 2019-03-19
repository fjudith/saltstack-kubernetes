output "gateway_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.proxy_vpn_ips.0.rendered}"]
}

output "proxy_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.proxy_vpn_ips.*.rendered}"]
}

output "etcd_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.etcd_vpn_ips.*.rendered}"]
}

output "master_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.master_vpn_ips.*.rendered}"]
}

output "node_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.node_vpn_ips.*.rendered}"]
}

output "vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.vpn_ips.*.rendered}"]
}

output "proxy_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.proxy_vpn_ipv6s.*.rendered}"]
}

output "etcd_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.etcd_vpn_ipv6s.*.rendered}"]
}

output "master_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.master_vpn_ipv6s.*.rendered}"]
}

output "node_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.node_vpn_ipv6s.*.rendered}"]
}

output "vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.vpn_ipv6s.*.rendered}"]
}

output "vpn_unit" {
  depends_on = ["null_resource.wireguard"]
  value      = "wg-quick@${var.vpn_interface}.service"
}

output "vpn_interface" {
  value = "${var.vpn_interface}"
}

output "vpn_port" {
  value = "${var.vpn_port}"
}

output "overlay_cidr" {
  value = "${var.overlay_cidr}"
}
