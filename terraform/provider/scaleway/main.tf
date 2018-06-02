variable "region" {
  description = "Scaleway hosting region: Paris (par1), Amsterdam (ams1)"
  default     = "par1"
}

variable "organization" {
  description = "Scaleway access_key"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "token" {
  description = "Scaleway secret_key"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "architecture" {
  description = "Operating system image base architecture"
  default     = "x86_64"
}

variable "image" {
  default = "Ubuntu Xenial"
}

variable "apt_packages" {
  type    = "list"
  default = []
}

variable "etcd_type" {
  default = "START1-XS"
}

variable "etcd_count" {
  default = 3
}

variable "master_type" {
  default = "START1-S"
}

variable "master_count" {
  default = 3
}

variable "node_type" {
  default = "START1-M"
}

variable "node_volume_size" {
  default = 50
}

variable "node_count" {
  default = 3
}

variable "proxy_type" {
  default = "START1-S"
}

variable "ssh_user" {
  description = "Username to connect the server"
  default     = "root"
}

variable "ssh_public_key" {
  description = "Path to your public SSH key path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  description = "Path to your private SSH key path"
  default     = "~/.ssh/id_rsa.insecure"
}

variable "ssh_bastion_host" {
  description = "Ip address, Hostname or FQDN of the SSH bastion hsot"
  default     = "ssh-bastion.domain.tld"
}

variable "web_proxy_host" {
  description = "Ip address, Hostname or FQDN of Web Proxy"
  default     = "web-proxy.domain.tld"
}

provider "scaleway" {
  organization = "${var.organization}"
  token        = "${var.token}"
  region       = "${var.region}"
  version      = "~> 1.4"
}

data "scaleway_image" "ubuntu" {
  architecture = "${var.architecture}"
  name         = "${var.image}"
}

data "scaleway_bootscript" "bootscript" {
  architecture = "${var.architecture}"
  name_filter  = "mainline 4.15.11 rev1"
}

resource "scaleway_ip" "public_ip" {
  count = "${var.etcd_count}"
}

##################################################
# Proxy 0
##################################################
resource "scaleway_server" "proxy00" {
  count      = 1
  name       = "proxy00"
  image      = "${data.scaleway_image.ubuntu.id}"
  bootscript = "${data.scaleway_bootscript.bootscript.id}"
  type       = "${var.proxy_type}"
  public_ip  = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state      = "running"
  tags       = ["proxy", "primary"]

  connection {
    type        = "ssh"
    host        = "${self.public_ip}"
    user        = "${var.ssh_user}"
    private_key = "${file(var.ssh_private_key)}"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://localhost:8888' >> /etc/environment",
      "echo 'https_proxy=http://localhost:8888' >> /etc/environment",
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw tinyproxy ${join(" ", var.apt_packages)}",
      "systemctl enable tinyproxy",
      "echo 'Allow 127.0.0.1' >> /etc/tinyproxy.conf",
      "echo 'Allow 192.168.0.0/16' >> /etc/tinyproxy.conf",
      "echo 'Allow 172.16.0.0/12' >> /etc/tinyproxy.conf",
      "echo 'Allow 10.0.0.0/8' >> /etc/tinyproxy.conf",
      "systemctl daemon-reload",
      "systemctl restart tinyproxy",
    ]
  }

  provisioner "file" {
    content     = "role: proxy"
    destination = "/etc/salt/grains"
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

  count      = 1
  name       = "proxy01"
  image      = "${data.scaleway_image.ubuntu.id}"
  bootscript = "${data.scaleway_bootscript.bootscript.id}"
  type       = "${var.proxy_type}"
  state      = "running"
  tags       = ["proxy", "secondary"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy00.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw ${join(" ", var.apt_packages)}",
    ]
  }

  provisioner "file" {
    content     = "role: proxy"
    destination = "/etc/salt/grains"
  }
}

##################################################
# etcd
##################################################
resource "scaleway_server" "etcd" {
  depends_on = ["scaleway_server.proxy00"]

  count      = "${var.etcd_count}"
  name       = "${format("etcd%02d", count.index)}"
  image      = "${data.scaleway_image.ubuntu.id}"
  bootscript = "${data.scaleway_bootscript.bootscript.id}"
  type       = "${var.etcd_type}"

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state = "running"
  tags  = ["kubernetes", "etcd"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy00.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw ${join(" ", var.apt_packages)}",
    ]
  }

  provisioner "file" {
    content     = "role: etcd"
    destination = "/etc/salt/grains"
  }
}

##################################################
# Kubernetes Master
##################################################
resource "scaleway_server" "master" {
  depends_on = ["scaleway_server.proxy00", "scaleway_server.etcd"]

  count      = "${var.master_count}"
  name       = "${format("master%02d", count.index)}"
  image      = "${data.scaleway_image.ubuntu.id}"
  bootscript = "${data.scaleway_bootscript.bootscript.id}"
  type       = "${var.master_type}"

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state = "running"
  tags  = ["kubernetes", "master"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy00.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw ${join(" ", var.apt_packages)}",
    ]
  }

  provisioner "file" {
    content     = "role: master"
    destination = "/etc/salt/grains"
  }
}

##################################################
# Kubernetes Node
##################################################
resource "scaleway_server" "node" {
  depends_on = ["scaleway_server.proxy00", "scaleway_server.master"]

  count      = "${var.node_count}"
  name       = "${format("node%02d", count.index)}"
  image      = "${data.scaleway_image.ubuntu.id}"
  bootscript = "${data.scaleway_bootscript.bootscript.id}"
  type       = "${var.node_type}"
  state      = "running"
  tags       = ["kubernetes", "nodes"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy00.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  volume {
    size_in_gb = "${var.node_volume_size}"
    type       = "l_ssd"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy00.0.private_ip}:8888' >> /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw ${join(" ", var.apt_packages)}",
    ]
  }

  provisioner "file" {
    content     = "role: node"
    destination = "/etc/salt/grains"
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

output "hostnames" {
  value = [
    "${scaleway_server.proxy00.*.name}",
    "${scaleway_server.proxy01.*.name}",
    "${scaleway_server.etcd.*.name}",
    "${scaleway_server.master.*.name}",
    "${scaleway_server.node.*.name}",
  ]
}

output "proxy_hostnames" {
  value = [
    "${scaleway_server.proxy00.*.name}",
    "${scaleway_server.proxy01.*.name}",
  ]
}

output "proxy_hostname" {
  value = [
    "${scaleway_server.proxy00.*.name}",
  ]
}

output "salt_minion" {
  value = [
    "${scaleway_server.proxy00.*.private_ip}",
    "${scaleway_server.proxy01.*.private_ip}",
    "${scaleway_server.etcd.*.private_ip}",
    "${scaleway_server.master.*.private_ip}",
    "${scaleway_server.node.*.private_ip}",
  ]
}

output "bastion_host" {
  value = "${scaleway_server.proxy00.0.public_ip}"
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

output "public_ips" {
  value = [
    "${scaleway_server.proxy00.*.public_ip}",
    "${scaleway_server.proxy01.*.public_ip}",
  ]
}
