##################################################
# Kubernetes Master
##################################################
resource "hcloud_server" "master" {
  depends_on = [hcloud_server.edge01, hcloud_server.etcd]

  count       = var.master_count
  name        = format("master%02d", count.index + 1)
  location    = var.location
  image       = var.image
  server_type = var.master_type
  ssh_keys    = var.ssh_keys
  user_data   = templatefile(
                  "${path.module}/../cloud-init/master_user-data.yaml",
                  {
                    SALT_MASTER_HOST = hcloud_server.edge01.0.name,
                    VPN_INTERFACE = var.vpn_interface,
                    VPN_IP_RANGE = var.vpn_iprange,
                    VPN_PORT = var.vpn_port,
                    PRIVATE_INTERFACE = "eth0"
                  }
                )
  labels = {
            app  = "kubernetes",
            role = "master",
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
      # "cloud-init status --long --wait",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }
}

data "template_file" "master_cloud-init" {
  count    = 1
  template = file("${path.module}/../cloud-init/master_user-data.yaml")
  vars = {
    SALT_MASTER_HOST     = hcloud_server.edge01.0.name
    VPN_INTERFACE        = var.vpn_interface
    VPN_IP_RANGE         = var.vpn_iprange
    VPN_PORT             = var.vpn_port
    PRIVATE_INTERFACE    = "eth0"
  }
}