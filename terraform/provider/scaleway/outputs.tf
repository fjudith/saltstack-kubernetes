output "private_ips" {
  value = [
    "${scaleway_server.edge01.*.private_ip}",
    "${scaleway_server.edge02.*.private_ip}",
    "${scaleway_server.etcd.*.private_ip}",
    "${scaleway_server.master.*.private_ip}",
    "${scaleway_server.node.*.private_ip}",
  ]
}

output "hostnames" {
  value = [
    "${scaleway_server.edge01.*.name}",
    "${scaleway_server.edge02.*.name}",
    "${scaleway_server.etcd.*.name}",
    "${scaleway_server.master.*.name}",
    "${scaleway_server.node.*.name}",
  ]
}

output "edge_hostnames" {
  value = [
    "${scaleway_server.edge01.*.name}",
    "${scaleway_server.edge02.*.name}",
  ]
}

output "etcd_hostnames" {
  value = [
    "${scaleway_server.etcd.*.name}",
  ]
}

output "master_hostnames" {
  value = [
    "${scaleway_server.master.*.name}",
  ]
}

output "node_hostnames" {
  value = [
    "${scaleway_server.node.*.name}",
  ]
}

output "edge_hostname" {
  value = [
    "${scaleway_server.edge01.*.name}",
  ]
}

output "salt_minion" {
  value = [
    "${scaleway_server.edge02.*.private_ip}",
    "${scaleway_server.etcd.*.private_ip}",
    "${scaleway_server.master.*.private_ip}",
    "${scaleway_server.node.*.private_ip}",
  ]
}

output "salt_syndic" {
  value = [
    "${scaleway_server.edge01.*.private_ip}",
  ]
}

output "bastion_host" {
  value = "${scaleway_server.edge01.0.public_ip}"
}

output "edge_private_ips" {
  value = [
    "${scaleway_server.edge01.*.private_ip}",
    "${scaleway_server.edge02.*.private_ip}",
  ]
}

output "etcd_private_ips" {
  value = ["${scaleway_server.etcd.*.private_ip}"]
}

output "etcd_public_ips" {
  value = ["${scaleway_server.etcd.*.public_ip}"]
}

output "master_private_ips" {
  value = ["${scaleway_server.master.*.private_ip}"]
}

output "master_public_ips" {
  value = ["${scaleway_server.master.*.public_ip}"]
}

output "node_private_ips" {
  value = ["${scaleway_server.node.*.private_ip}"]
}

output "node_public_ips" {
  value = ["${scaleway_server.node.*.public_ip}"]
}

output "edge01_private_ips" {
  value = ["${scaleway_server.edge01.*.private_ip}"]
}

output "edge02_private_ips" {
  value = ["${scaleway_server.edge02.*.private_ip}"]
}

output "public_ip" {
  value = ["${scaleway_server.edge01.*.public_ip}"]
}

output "public_ips" {
  value = [
    "${scaleway_server.edge01.*.public_ip}",
    "${scaleway_server.edge02.*.public_ip}",
  ]
}

output "private_network_interface" {
  value = "enp0s2"
}