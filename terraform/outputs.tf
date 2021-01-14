output "hostnames" {
  value = module.provider.hostnames
}

output "edge_hostnames" {
  value = module.provider.edge_hostnames
}

output "private_ips" {
  value = module.provider.private_ips
}

output "vpn_ips" {
  value = module.wireguard.vpn_ips
}

output "public_ips" {
  value = module.provider.public_ips
}