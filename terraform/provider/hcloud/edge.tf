##################################################
# proxy01
##################################################
resource "hcloud_server" "edge01" {
  count       = 1
  name        = "edge01"
  location    = var.location
  image       = var.image
  server_type = var.edge_type
  ssh_keys    = var.ssh_keys
  user_data   = data.template_file.edge01_cloud-init.rendered
  labels = {
    app  = "kubernetes"
    role = "edge_router"
    salt = "master"
  }

  connection {
    type        = "ssh"
    host        = self.ipv4_address
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
    agent       = false
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "cloud-init status --long --wait",
    ]
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'http_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #     "echo 'https_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #   ]
  # }

  provisioner "file" {
    content     = file(var.ssh_private_key)
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/id_rsa",
    ]
  }

  provisioner "file" {
    content     = file(var.ssh_public_key)
    destination = "~/.ssh/id_rsa.pub"
  }
}

##################################################
# edge02
##################################################
resource "hcloud_server" "edge02" {
  depends_on = [hcloud_server.edge01]

  count       = 1
  name        = "edge02"
  location    = var.location
  image       = var.image
  server_type = var.edge_type
  ssh_keys    = var.ssh_keys
  user_data   = data.template_file.edge02_cloud-init.rendered
  labels = {
    app  = "kubernetes"
    role = "edge_router"
    salt = "master"
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

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'http_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #     "echo 'https_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #   ]
  # }

  provisioner "file" {
    content     = file(var.ssh_private_key)
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/id_rsa",
    ]
  }

  provisioner "file" {
    content     = file(var.ssh_public_key)
    destination = "~/.ssh/id_rsa.pub"
  }
}

data "template_file" "edge01_cloud-init" {
  template = file("${path.module}/../cloud-init/edge_user-data.yaml")
  vars = {
    SALT_MASTER_HOST     = "localhost"
    VPN_INTERFACE        = var.vpn_interface
    VPN_IP_RANGE         = var.vpn_iprange
    VPN_PORT             = var.vpn_port
    PRIVATE_INTERFACE    = "eth0"
  }
}

data "template_file" "edge02_cloud-init" {
  template = file("${path.module}/../cloud-init/edge_user-data.yaml")
  vars = {
    SALT_MASTER_HOST     = hcloud_server.edge01.0.name
    VPN_INTERFACE        = var.vpn_interface
    VPN_IP_RANGE         = var.vpn_iprange
    VPN_PORT             = var.vpn_port
    PRIVATE_INTERFACE    = "eth0"
  }
}