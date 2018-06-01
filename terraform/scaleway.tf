##################################################
# Scaleway
##################################################
provider "scaleway" {
  organization = "${var.scaleway_organization}"
  token        = "${var.scaleway_token}"
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
    source      = "security/ufw/scripts/ufw.sh"
    destination = "/tmp/ufw.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ufw.sh",
      "/tmp/ufw.sh ${module.zerotier.cidr}",
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
    source      = "security/ufw/scripts/ufw.sh"
    destination = "/tmp/ufw.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ufw.sh",
      "/tmp/ufw.sh ${module.zerotier.cidr}",
    ]
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo proxy01=\"${self.public_ip}\" >> .terraform/public_ips.txt"
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

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.public_ip},\" >> .terraform/etcd_public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.private_ip},\" >> .terraform/etcd_private_ips.txt"
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

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.public_ip},\" >> .terraform/master_public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.private_ip},\" >> .terraform/master_private_ips.txt"
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

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.public_ip},\" >> .terraform/node_public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "printf \"${self.private_ip},\" >> .terraform/node_private_ips.txt"
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

output "private_ips" {
  value = [
    "${scaleway_server.proxy00.*.private_ip}",
    "${scaleway_server.proxy01.*.private_ip}",
    "${scaleway_server.etcd.*.private_ip}",
    "${scaleway_server.master.*.private_ip}",
    "${scaleway_server.node.*.private_ip}",
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

output "proxy00_private_ips" {
  value = ["${scaleway_server.proxy00.*.private_ip}"]
}

output "proxy01_private_ips" {
  value = ["${scaleway_server.proxy01.*.private_ip}"]
}

output "public_ip" {
  value = ["${scaleway_server.proxy00.*.public_ip}"]
}

module "zerotier" {
  source = "security/zerotier"

  count            = "${var.etcd_instance_count + var.master_instance_count + var.node_instance_count + 1}"
  bastion_host     = "${scaleway_server.proxy00.0.public_ip}"
  bit              = "${var.proxyIP}"
  zerotier_api_key = "${var.zerotier_api_key}"
  zerotier_cidr    = "${var.zerotier_cidr}"

  connections = [
    "${scaleway_server.proxy01.*.private_ip}",
    "${scaleway_server.etcd.*.private_ip}",
    "${scaleway_server.master.*.private_ip}",
    "${scaleway_server.node.*.private_ip}",
  ]
}

module "salt-minion" {
  source = "management/salt-minion"

  count            = "${var.etcd_instance_count + var.master_instance_count + var.node_instance_count + 2}"
  bastion_host     = "${scaleway_server.proxy00.0.public_ip}"
  salt_master_host = "${var.saltsyndic_host}"

  connections = [
    "${scaleway_server.proxy00.*.private_ip}",
    "${scaleway_server.proxy01.*.private_ip}",
    "${scaleway_server.etcd.*.private_ip}",
    "${scaleway_server.master.*.private_ip}",
    "${scaleway_server.node.*.private_ip}",
  ]
}
