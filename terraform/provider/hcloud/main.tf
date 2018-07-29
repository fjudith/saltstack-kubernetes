variable "location" {
  description = "Hetzner cloud hosting region: Nuremberg (nbg1), Falkenstein (fsn1), Helsinki (hel1)"
  default     = "nbg1"
}

variable "token" {
  description = "Hetzner cloud token"
  default     = "12345678-1234-1234-1234-123456789abc"
}

variable "ssh_keys" {
  type = "list"
}

variable "image" {
  type    = "string"
  default = "ubuntu-18.04"
}

variable "apt_packages" {
  type    = "list"
  default = []
}

variable "etcd_type" {
  type    = "string"
  default = "cx11"
}

variable "etcd_count" {
  default = 3
}

variable "master_type" {
  default = "cx11"
}

variable "master_count" {
  default = 3
}

variable "node_type" {
  default = "cx41"
}

variable "node_count" {
  default = 3
}

variable "proxy_type" {
  default = "cx11"
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

provider "hcloud" {
  token = "${var.token}"
}

##################################################
# Proxy 0
##################################################
resource "hcloud_server" "proxy01" {
  count       = 1
  name        = "proxy01"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.proxy_type}"
  ssh_keys    = ["${var.ssh_keys}"]

  connection {
    type        = "ssh"
    host        = "${self.ipv4_address}"
    user        = "${var.ssh_user}"
    private_key = "${file(var.ssh_private_key)}"
    agent       = false
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a  /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw tinyproxy ${join(" ", var.apt_packages)}",
      "echo 'MaxSessions 100' | tee -a  /etc/ssh/sshd_config",
      "systemctl reload sshd",
      "systemctl enable tinyproxy",
      "echo 'Allow 127.0.0.1' | tee -a  /etc/tinyproxy.conf",
      "echo 'Allow 192.168.0.0/16' | tee -a  /etc/tinyproxy.conf",
      "echo 'Allow 172.16.0.0/12' | tee -a  /etc/tinyproxy.conf",
      "echo 'Allow 10.0.0.0/8' | tee -a  /etc/tinyproxy.conf",
      "systemctl daemon-reload",
      "systemctl start tinyproxy",
      "echo 'http_proxy=http://localhost:8888' | tee -a  /etc/environment",
      "echo 'https_proxy=http://localhost:8888' | tee -a  /etc/environment",
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

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/id_rsa",
    ]
  }

  provisioner "file" {
    content     = "${file(var.ssh_public_key)}"
    destination = "~/.ssh/id_rsa.pub"
  }
}

##################################################
# proxy02
##################################################
resource "hcloud_server" "proxy02" {
  depends_on = ["hcloud_server.proxy01"]

  count       = 1
  name        = "proxy02"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.proxy_type}"
  ssh_keys    = ["${var.ssh_keys}"]

  connection {
    type                = "ssh"
    host                = "${self.ipv4_address}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a  /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw ${join(" ", var.apt_packages)}",
      "echo 'MaxSessions 100' | tee -a  /etc/ssh/sshd_config",
      "systemctl reload sshd",
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
resource "hcloud_server" "etcd" {
  depends_on = ["hcloud_server.proxy01"]

  count       = "${var.etcd_count}"
  name        = "${format("etcd%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.etcd_type}"
  ssh_keys    = ["${var.ssh_keys}"]

  connection {
    type                = "ssh"
    host                = "${self.ipv4_address}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a  /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
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
resource "hcloud_server" "master" {
  depends_on = ["hcloud_server.proxy01", "hcloud_server.etcd"]

  count       = "${var.master_count}"
  name        = "${format("master%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.master_type}"
  ssh_keys    = ["${var.ssh_keys}"]

  connection {
    type                = "ssh"
    host                = "${self.ipv4_address}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a  /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "apt-get update -yqq",
      "apt-get install -yqq apt-transport-https ufw git ${join(" ", var.apt_packages)}",
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
resource "hcloud_server" "node" {
  depends_on = ["hcloud_server.proxy01", "hcloud_server.master"]

  count       = "${var.node_count}"
  name        = "${format("node%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.node_type}"
  ssh_keys    = ["${var.ssh_keys}"]

  connection {
    type                = "ssh"
    host                = "${self.ipv4_address}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a  /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a  /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
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
    "${hcloud_server.proxy01.*.ipv4_address}",
    "${hcloud_server.proxy02.*.ipv4_address}",
    "${hcloud_server.etcd.*.ipv4_address}",
    "${hcloud_server.master.*.ipv4_address}",
    "${hcloud_server.node.*.ipv4_address}",
  ]
}

output "hostnames" {
  value = [
    "${hcloud_server.proxy01.*.name}",
    "${hcloud_server.proxy02.*.name}",
    "${hcloud_server.etcd.*.name}",
    "${hcloud_server.master.*.name}",
    "${hcloud_server.node.*.name}",
  ]
}

output "proxy_hostnames" {
  value = [
    "${hcloud_server.proxy01.*.name}",
    "${hcloud_server.proxy02.*.name}",
  ]
}

output "etcd_hostnames" {
  value = [
    "${hcloud_server.etcd.*.name}",
  ]
}

output "master_hostnames" {
  value = [
    "${hcloud_server.master.*.name}",
  ]
}

output "node_hostnames" {
  value = [
    "${hcloud_server.node.*.name}",
  ]
}

output "proxy_hostname" {
  value = [
    "${hcloud_server.proxy01.*.name}",
  ]
}

output "salt_minion" {
  value = [
    "${hcloud_server.proxy02.*.ipv4_address}",
    "${hcloud_server.etcd.*.ipv4_address}",
    "${hcloud_server.master.*.ipv4_address}",
    "${hcloud_server.node.*.ipv4_address}",
  ]
}

output "salt_syndic" {
  value = [
    "${hcloud_server.proxy01.*.ipv4_address}",
  ]
}

output "bastion_host" {
  value = "${hcloud_server.proxy01.0.ipv4_address}"
}

output "proxy_private_ips" {
  value = [
    "${hcloud_server.proxy01.*.ipv4_address}",
    "${hcloud_server.proxy02.*.ipv4_address}",
  ]
}

output "etcd_private_ips" {
  value = ["${hcloud_server.etcd.*.ipv4_address}"]
}

output "etcd_public_ips" {
  value = ["${hcloud_server.etcd.*.ipv4_address}"]
}

output "master_private_ips" {
  value = ["${hcloud_server.master.*.ipv4_address}"]
}

output "master_public_ips" {
  value = ["${hcloud_server.master.*.ipv4_address}"]
}

output "node_private_ips" {
  value = ["${hcloud_server.node.*.ipv4_address}"]
}

output "node_public_ips" {
  value = ["${hcloud_server.node.*.ipv4_address}"]
}

output "proxy01_private_ips" {
  value = ["${hcloud_server.proxy01.*.ipv4_address}"]
}

output "proxy02_private_ips" {
  value = ["${hcloud_server.proxy02.*.ipv4_address}"]
}

output "public_ip" {
  value = ["${hcloud_server.proxy01.*.ipv4_address}"]
}

output "public_ips" {
  value = [
    "${hcloud_server.proxy01.*.ipv4_address}",
    "${hcloud_server.proxy02.*.ipv4_address}",
  ]
}

output "private_network_interface" {
  value = "eth0"
}
