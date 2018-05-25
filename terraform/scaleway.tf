provider "scaleway" {
  organization = "${var.organization_key}"
  token        = "${var.secret_key}"
  region       = "${var.region}"
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

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo ${format("etcd%02d", count.index)}=\"${self.public_ip}\" >> public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo ${format("etcd%02d", count.index)}=\"${self.private_ip}\" >> private_ips.txt"
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
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }
}

##################################################
# Kubernetes Master
##################################################
resource "scaleway_server" "master" {
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

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo ${format("master%02d", count.index)}=\"${self.public_ip}\" >> public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo ${format("master%02d", count.index)}=\"${self.private_ip}\" >> private_ips.txt"
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
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }
}

##################################################
# Kubernetes Node
##################################################
resource "scaleway_server" "node" {
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

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo ${format("node%02d", count.index)}=\"${self.public_ip}\" >> public_ips.txt"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo ${format("node%02d", count.index)}=\"${self.private_ip}\" >> private_ips.txt"
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
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
    ]
  }
}

##################################################
# Proxy 0
##################################################
resource "scaleway_server" "proxy0" {
  count     = 1
  name      = "proxy0"
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

  provisioner "local-exec" {
    command = "echo proxy0=\"${self.public_ip}\" >> public_ips.txt"
  }

  provisioner "local-exec" {
    command = "echo proxy0=\"${self.public_ip}\" >> private_ips.txt"
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
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
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
# Proxy1
##################################################
resource "scaleway_server" "proxy1" {
  count = 1
  name  = "proxy1"
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

  provisioner "local-exec" {
    command = "echo proxy1=\"${self.public_ip}\" >> public_ips.txt"
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
      "echo 'http_proxy=${var.web_proxy_host}' >> /etc/environment",
      "echo 'https_proxy=${var.web_proxy_host}' >> /etc/environment",
      "chmod +x /tmp/install-salt-minion.sh",
      "/tmp/install-salt-minion.sh",
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

output "proxy0_private_ips" {
  value = ["${scaleway_server.proxy0.*.private_ip}"]
}

output "proxy1_private_ips" {
  value = ["${scaleway_server.proxy1.*.private_ip}"]
}

output "public_ip" {
  value = ["${scaleway_server.proxy0.*.public_ip}"]
}
