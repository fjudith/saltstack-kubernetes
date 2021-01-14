##################################################
# Kubernetes Node
##################################################
resource "hcloud_server" "node" {
  depends_on = [hcloud_server.edge01, hcloud_server.master]

  count       = var.node_count
  name        = format("node%02d", count.index + 1)
  location    = var.location
  image       = var.image
  server_type = var.node_type
  ssh_keys    = var.ssh_keys
  user_data   = templatefile(
                  "${path.module}/../cloud-init/node_user-data.yaml",
                  {
                    SALT_MASTER_HOST = hcloud_server.edge01.0.name,
                    VPN_INTERFACE = var.vpn_interface,
                    VPN_IP_RANGE = var.vpn_iprange,
                    VPN_PORT = var.vpn_port,
                    PRIVATE_INTERFACE = "eth0"
                  }
                )
  labels = {
            app  = "kubernetes"
            role = "node"
            salt = "minion"
           }

  connection {
    type                = "ssh"
    host                = self.ipv4_address
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = hcloud_server.edge01.0.ipv4_address
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --long --wait",
    ]
  }
}

data "template_file" "node_cloud-init" {
  count    = 1
  template = file("${path.module}/../cloud-init/node_user-data.yaml")
  vars = {
    SALT_MASTER_HOST     = hcloud_server.edge01.0.name
    VPN_INTERFACE        = var.vpn_interface
    VPN_IP_RANGE         = var.vpn_iprange
    VPN_PORT             = var.vpn_port
    PRIVATE_INTERFACE    = "eth0"
  }
}