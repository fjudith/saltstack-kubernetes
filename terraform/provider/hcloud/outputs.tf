output "private_ips" {
  value = [
    "${hcloud_server.proxy01.*.ipv4_address}",
    "${hcloud_server.proxy02.*.ipv4_address}",
    "${hcloud_server.etcd.*.ipv4_address}",
    "${hcloud_server.master.*.ipv4_address}",
    "${hcloud_server.node.*.ipv4_address}",
  ]
}

output "hostnames" {
  value = [
    "${hcloud_server.proxy01.*.name}",
    "${hcloud_server.proxy02.*.name}",
    "${hcloud_server.etcd.*.name}",
    "${hcloud_server.master.*.name}",
    "${hcloud_server.node.*.name}",
  ]
}

output "proxy_hostnames" {
  value = [
    "${hcloud_server.proxy01.*.name}",
    "${hcloud_server.proxy02.*.name}",
  ]
}

output "etcd_hostnames" {
  value = [
    "${hcloud_server.etcd.*.name}",
  ]
}

output "master_hostnames" {
  value = [
    "${hcloud_server.master.*.name}",
  ]
}

output "node_hostnames" {
  value = [
    "${hcloud_server.node.*.name}",
  ]
}

output "proxy_hostname" {
  value = [
    "${hcloud_server.proxy01.*.name}",
  ]
}

output "salt_minion" {
  value = [
    "${hcloud_server.proxy02.*.ipv4_address}",
    "${hcloud_server.etcd.*.ipv4_address}",
    "${hcloud_server.master.*.ipv4_address}",
    "${hcloud_server.node.*.ipv4_address}",
  ]
}

output "salt_syndic" {
  value = [
    "${hcloud_server.proxy01.*.ipv4_address}",
  ]
}

output "bastion_host" {
  value = "${hcloud_floating_ip.proxy.ip_address}"
}

output "proxy_private_ips" {
  value = [
    "${hcloud_server.proxy01.*.ipv4_address}",
    "${hcloud_server.proxy02.*.ipv4_address}",
  ]
}

output "etcd_private_ips" {
  value = ["${hcloud_server.etcd.*.ipv4_address}"]
}

output "etcd_public_ips" {
  value = ["${hcloud_server.etcd.*.ipv4_address}"]
}

output "master_private_ips" {
  value = ["${hcloud_server.master.*.ipv4_address}"]
}

output "master_public_ips" {
  value = ["${hcloud_server.master.*.ipv4_address}"]
}

output "node_private_ips" {
  value = ["${hcloud_server.node.*.ipv4_address}"]
}

output "node_public_ips" {
  value = ["${hcloud_server.node.*.ipv4_address}"]
}

output "proxy01_private_ips" {
  value = ["${hcloud_server.proxy01.*.ipv4_address}"]
}

output "proxy02_private_ips" {
  value = ["${hcloud_server.proxy02.*.ipv4_address}"]
}

output "public_ip" {
  value = ["${hcloud_floating_ip.proxy.ip_address}"]
}

output "public_ips" {
  value = [
    "${hcloud_server.proxy01.*.ipv4_address}",
    "${hcloud_server.proxy02.*.ipv4_address}",
  ]
}

output "private_network_interface" {
  value = "eth0"
}
