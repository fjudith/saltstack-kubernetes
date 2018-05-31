##################################################
# Zero tiers MeshVPN
# https://github.com/cormacrelf/terraform-provider-zerotier
##################################################
provider "zerotier" {
  api_key = "${var.zerotier_api_key}"
  version = "~>0.0"
}

resource "zerotier_network" "kubernetes" {
  name = "kubernetes"

  # auto-assign v4 addresses to devices
  assignment_pool {
    cidr = "${var.zerotier_cidr}"
  }

  # route requests to the cidr block on each device through zerotier
  route {
    target = "${var.zerotier_cidr}"
  }
}

##################################################
# Scaleway
##################################################
provider "scaleway" {
  organization = "${var.organization_key}"
  token        = "${var.secret_key}"
  region       = "${var.region}"
  version      = "~> 1.4"
}

data "scaleway_image" "ubuntu" {
  architecture = "${var.architecture}"
  name         = "${var.image}"
}

resource "scaleway_ip" "public_ip" {
  count = "${var.etcd_instance_count}"
}

##################################################
# etcd
##################################################
resource "scaleway_server" "etcd" {
  count = "${var.etcd_instance_count}"
  name  = "${format("etcd%02d", count.index)}"
  image = "${data.scaleway_image.ubuntu.id}"
  type  = "${var.etcd_instance_type}"

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state = "running"
  tags  = ["kubernetes", "etcd"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.ssh_bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
    ]
  }

  provisioner "file" {
    source      = "lib/install-zerotier.sh"
    destination = "/tmp/install-zerotier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-zerotier.sh",
      "/tmp/install-zerotier.sh ${var.zerotier_api_key} ${zerotier_network.kubernetes.id} ${cidrhost(var.zerotier_cidr, var.etcdIP + count.index + 1)}",
    ]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.public_ip},\" >> .terraform/etcd_public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.private_ip},\" >> .terraform/etcd_private_ips.txt"
  }

  provisioner "file" {
    source      = "lib/install-salt-minion.sh"
    destination = "/tmp/install-salt-minion.sh"
  }

  provisioner "file" {
    content     = "SALTMASTER=${var.saltsyndic_host}"
    destination = "/tmp/saltmaster.host"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }

  provisioner "file" {
    content     = "master: ${var.saltsyndic_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: etcd"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-minion",
    ]
  }
}

##################################################
# Kubernetes Master
##################################################
resource "scaleway_server" "master" {
  depends_on = ["scaleway_server.etcd"]

  count = "${var.master_instance_count}"
  name  = "${format("master%02d", count.index)}"
  image = "${data.scaleway_image.ubuntu.id}"
  type  = "${var.master_instance_type}"

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state = "running"
  tags  = ["kubernetes", "master"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.ssh_bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
    ]
  }

  provisioner "file" {
    source      = "lib/install-zerotier.sh"
    destination = "/tmp/install-zerotier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-zerotier.sh",
      "/tmp/install-zerotier.sh ${var.zerotier_api_key} ${zerotier_network.kubernetes.id} ${cidrhost(var.zerotier_cidr, var.masterIP + count.index + 1)}",
    ]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.public_ip},\" >> .terraform/master_public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.private_ip},\" >> .terraform/master_private_ips.txt"
  }

  provisioner "file" {
    source      = "lib/install-salt-minion.sh"
    destination = "/tmp/install-salt-minion.sh"
  }

  provisioner "file" {
    content     = "SALTMASTER=${var.saltsyndic_host}"
    destination = "/tmp/saltmaster.host"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }

  provisioner "file" {
    content     = "master: ${var.saltsyndic_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: master"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-minion",
    ]
  }
}

##################################################
# Kubernetes Node
##################################################
resource "scaleway_server" "node" {
  depends_on = ["scaleway_server.master"]

  count = "${var.node_instance_count}"
  name  = "${format("node%02d", count.index)}"
  image = "${data.scaleway_image.ubuntu.id}"
  type  = "${var.node_instance_type}"

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state = "running"
  tags  = ["kubernetes", "nodes"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.ssh_bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  volume {
    size_in_gb = 50
    type       = "l_ssd"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
    ]
  }

  provisioner "file" {
    source      = "lib/install-zerotier.sh"
    destination = "/tmp/install-zerotier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-zerotier.sh",
      "/tmp/install-zerotier.sh ${var.zerotier_api_key} ${zerotier_network.kubernetes.id} ${cidrhost(var.zerotier_cidr, var.nodeIP + count.index + 1)}",
    ]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.public_ip},\" >> .terraform/node_public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.private_ip},\" >> .terraform/node_private_ips.txt"
  }

  provisioner "file" {
    source      = "lib/install-salt-minion.sh"
    destination = "/tmp/install-salt-minion.sh"
  }

  provisioner "file" {
    content     = "SALTMASTER=${var.saltsyndic_host}"
    destination = "/tmp/saltmaster.host"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }

  provisioner "file" {
    content     = "master: ${var.saltsyndic_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: node"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-minion",
    ]
  }
}

##################################################
# Proxy 0
##################################################
resource "scaleway_server" "proxy00" {
  count     = 1
  name      = "proxy00"
  image     = "${data.scaleway_image.ubuntu.id}"
  type      = "${var.proxy_instance_type}"
  public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state     = "running"
  tags      = ["proxy", "primary"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.ssh_bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
    ]
  }

  provisioner "file" {
    source      = "lib/install-ufw.sh"
    destination = "/tmp/install-ufw.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-ufw.sh",
      "/tmp/install-ufw.sh ${var.zerotier_cidr}",
    ]
  }

  provisioner "file" {
    source      = "lib/install-zerotier.sh"
    destination = "/tmp/install-zerotier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-zerotier.sh",
      "/tmp/install-zerotier.sh ${var.zerotier_api_key} ${zerotier_network.kubernetes.id} ${cidrhost(var.zerotier_cidr, var.proxyIP + 1)}",
    ]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo proxy00=\"${self.public_ip}\" >> .terraform/public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo proxy00=\"${self.public_ip}\" >> .terraform/private_ips.txt"
  }

  provisioner "file" {
    source      = "lib/install-salt-minion.sh"
    destination = "/tmp/install-salt-minion.sh"
  }

  provisioner "file" {
    content     = "SALTMASTER=${var.saltsyndic_host}"
    destination = "/tmp/saltmaster.host"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }

  provisioner "file" {
    content     = "master: ${var.saltsyndic_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: proxy"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-minion",
    ]
  }

  provisioner "file" {
    content     = "${file(var.ssh_private_key)}"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "file" {
    content     = "${file(var.ssh_public_key)}"
    destination = "~/.ssh/id_rsa.pub"
  }
}

##################################################
# proxy01
##################################################
resource "scaleway_server" "proxy01" {
  depends_on = ["scaleway_server.proxy00"]

  count = 1
  name  = "proxy01"
  image = "${data.scaleway_image.ubuntu.id}"
  type  = "${var.proxy_instance_type}"
  state = "running"
  tags  = ["proxy", "secondary"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.ssh_bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
    ]
  }

  provisioner "file" {
    source      = "lib/install-ufw.sh"
    destination = "/tmp/install-ufw.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-ufw.sh",
      "/tmp/install-ufw.sh ${var.zerotier_cidr}",
    ]
  }

  provisioner "file" {
    source      = "lib/install-zerotier.sh"
    destination = "/tmp/install-zerotier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-zerotier.sh",
      "/tmp/install-zerotier.sh ${var.zerotier_api_key} ${zerotier_network.kubernetes.id} ${cidrhost(var.zerotier_cidr, var.proxyIP + 2)}",
    ]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo proxy01=\"${self.public_ip}\" >> .terraform/public_ips.txt"
  }

  provisioner "file" {
    source      = "lib/install-salt-minion.sh"
    destination = "/tmp/install-salt-minion.sh"
  }

  provisioner "file" {
    content     = "SALTMASTER=${var.saltsyndic_host}"
    destination = "/tmp/saltmaster.host"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }

  provisioner "file" {
    content     = "master: ${var.saltsyndic_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: proxy"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-minion",
    ]
  }
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

output "proxy00_private_ips" {
  value = ["${scaleway_server.proxy00.*.private_ip}"]
}

output "proxy01_private_ips" {
  value = ["${scaleway_server.proxy01.*.private_ip}"]
}

output "public_ip" {
  value = ["${scaleway_server.proxy00.*.public_ip}"]
}
