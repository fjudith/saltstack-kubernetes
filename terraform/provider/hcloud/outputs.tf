output "private_ips" {
  value = flatten([
    hcloud_server.edge01.*.ipv4_address,
    hcloud_server.edge02.*.ipv4_address,
    hcloud_server.etcd.*.ipv4_address,
    hcloud_server.master.*.ipv4_address,
    hcloud_server.node.*.ipv4_address,
  ])
}

output "hostnames" {
  value = flatten([
    hcloud_server.edge01.*.name,
    hcloud_server.edge02.*.name,
    hcloud_server.etcd.*.name,
    hcloud_server.master.*.name,
    hcloud_server.node.*.name,
  ])
}

output "edge_hostnames" {
  value = flatten([
    hcloud_server.edge01.*.name,
    hcloud_server.edge02.*.name,
  ])
}

output "etcd_hostnames" {
  value = hcloud_server.etcd.*.name
}

output "master_hostnames" {
  value = hcloud_server.master.*.name
}

output "node_hostnames" {
  value = hcloud_server.node.*.name
}

output "edge_hostname" {
  value = hcloud_server.edge01.*.name
}

output "salt_minion" {
  value = flatten([
    hcloud_server.edge02.*.ipv4_address,
    hcloud_server.etcd.*.ipv4_address,
    hcloud_server.master.*.ipv4_address,
    hcloud_server.node.*.ipv4_address,
  ])
}

output "salt_syndic" {
  value = hcloud_server.edge01.*.ipv4_address
}

output "bastion_host" {
  value = hcloud_server.edge01.0.ipv4_address
}

output "edge_private_ips" {
  value = flatten([
    hcloud_server.edge01.*.ipv4_address,
    hcloud_server.edge02.*.ipv4_address,
  ])
}

output "etcd_private_ips" {
  value = hcloud_server.etcd.*.ipv4_address
}

output "etcd_public_ips" {
  value = hcloud_server.etcd.*.ipv4_address
}

output "master_private_ips" {
  value = hcloud_server.master.*.ipv4_address
}

output "master_public_ips" {
  value = hcloud_server.master.*.ipv4_address
}

output "node_private_ips" {
  value = hcloud_server.node.*.ipv4_address
}

output "node_public_ips" {
  value = hcloud_server.node.*.ipv4_address
}

output "edge01_private_ips" {
  value = hcloud_server.edge01.*.ipv4_address
}

output "edge02_private_ips" {
  value = hcloud_server.edge02.*.ipv4_address
}

output "public_ip" {
  value = hcloud_server.edge01.*.ipv4_address
}

output "public_ips" {
  value = flatten([
    hcloud_server.edge01.*.ipv4_address,
    hcloud_server.edge02.*.ipv4_address,
  ])
}

output "private_network_interface" {
  value = "eth0"
}
