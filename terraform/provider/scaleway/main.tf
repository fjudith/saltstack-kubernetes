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
resource "scaleway_server" "proxy01" {
  count       = 1
  name        = "proxy01"
  image       = "${data.scaleway_image.ubuntu.id}"
  bootscript  = "${data.scaleway_bootscript.bootscript.id}"
  type        = "${var.proxy_type}"
  public_ip   = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state       = "running"
  enable_ipv6 = true
  tags        = ["proxy", "primary"]

  connection {
    type        = "ssh"
    host        = "${self.public_ip}"
    user        = "${var.ssh_user}"
    private_key = "${file(var.ssh_private_key)}"
    agent       = false
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /var/lib/apt/lists/*",
      "apt-get update -yqq",
      "apt-get install --no-install-recommends -yqq apt-transport-https conntrack ca-certificates tinyproxy ${join(" ", var.apt_packages)}",
      "echo 'MaxSessions 100' | tee -a  /etc/ssh/sshd_config",
      "systemctl reload sshd",
      "systemctl enable tinyproxy",
      "echo 'Allow 127.0.0.1' | tee -a  /etc/tinyproxy.conf",
      "echo 'Allow 192.168.0.0/16' | tee -a  /etc/tinyproxy.conf",
      "echo 'Allow 172.16.0.0/12' | tee -a  /etc/tinyproxy.conf",
      "echo 'Allow 10.0.0.0/8' | tee -a  /etc/tinyproxy.conf",
      "systemctl daemon-reload",
      "systemctl start tinyproxy.service",
      "systemctl is-active tinyproxy.service",
      "echo 'http_proxy=http://localhost:8888' | tee -a  /etc/environment",
      "echo 'https_proxy=http://localhost:8888' | tee -a  /etc/environment",
    ]
  }

provisioner "remote-exec" {
    inline = [
      "echo '*    soft nofile 1048576' | tee -a /etc/security/limits.conf", 
      "echo '*    hard nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root soft nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root hard nofile 1048576' | tee -a /etc/security/limits.conf",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'session required pam_limits.so' | tee -a  /etc/pam.d/common-session",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'fs.file-max=2097152' | tee -a /etc/sysctl.conf",
      "echo 'fs.nr_open=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe ip_conntrack",
      "echo '1024 65535' | tee -a /proc/sys/net/ipv4/ip_local_port_range",
      "echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.core.somaxconn=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
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

  provisioner "remote-exec" {
    inline = [
      "systemctl restart tinyproxy",
      "systemctl status tinyproxy --no-pager",
    ]
  }
}

##################################################
# proxy02
##################################################
resource "scaleway_server" "proxy02" {
  depends_on = ["scaleway_server.proxy01"]

  count       = 1
  name        = "proxy02"
  image       = "${data.scaleway_image.ubuntu.id}"
  bootscript  = "${data.scaleway_bootscript.bootscript.id}"
  type        = "${var.proxy_type}"
  state       = "running"
  enable_ipv6 = true
  tags        = ["proxy", "secondary"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy01.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /var/lib/apt/lists/*",
      "apt-get update -yqq",
      "apt-get install --no-install-recommends -yqq apt-transport-https conntrack ca-certificates ${join(" ", var.apt_packages)}",
      "echo 'MaxSessions 100' | tee -a  /etc/ssh/sshd_config",
      "systemctl reload sshd",
    ]
  }

 provisioner "remote-exec" {
    inline = [
      "echo '*    soft nofile 1048576' | tee -a /etc/security/limits.conf", 
      "echo '*    hard nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root soft nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root hard nofile 1048576' | tee -a /etc/security/limits.conf",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'session required pam_limits.so' | tee -a  /etc/pam.d/common-session",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'fs.file-max=2097152' | tee -a /etc/sysctl.conf",
      "echo 'fs.nr_open=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe ip_conntrack",
      "echo '1024 65535' | tee -a /proc/sys/net/ipv4/ip_local_port_range",
      "echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.core.somaxconn=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
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
  depends_on = ["scaleway_server.proxy01"]

  count       = "${var.etcd_count}"
  name        = "${format("etcd%02d", count.index + 1)}"
  image       = "${data.scaleway_image.ubuntu.id}"
  bootscript  = "${data.scaleway_bootscript.bootscript.id}"
  type        = "${var.etcd_type}"
  enable_ipv6 = true

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state = "running"
  tags  = ["kubernetes", "etcd"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy01.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /var/lib/apt/lists/*",
      "apt-get update -yqq",
      "apt-get install --no-install-recommends -yqq apt-transport-https conntrack ca-certificates ${join(" ", var.apt_packages)}",
    ]
  }

provisioner "remote-exec" {
    inline = [
      "echo '*    soft nofile 1048576' | tee -a /etc/security/limits.conf", 
      "echo '*    hard nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root soft nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root hard nofile 1048576' | tee -a /etc/security/limits.conf",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'session required pam_limits.so' | tee -a  /etc/pam.d/common-session",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'fs.file-max=2097152' | tee -a /etc/sysctl.conf",
      "echo 'fs.nr_open=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe ip_conntrack",
      "echo '1024 65535' | tee -a /proc/sys/net/ipv4/ip_local_port_range",
      "echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.core.somaxconn=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
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
  depends_on = ["scaleway_server.proxy01", "scaleway_server.etcd"]

  count      = "${var.master_count}"
  name       = "${format("master%02d", count.index + 1)}"
  image      = "${data.scaleway_image.ubuntu.id}"
  bootscript = "${data.scaleway_bootscript.bootscript.id}"
  type       = "${var.master_type}"

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state       = "running"
  enable_ipv6 = true
  tags        = ["kubernetes", "master"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy01.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /var/lib/apt/lists/*",
      "apt-get update -yqq",
      "apt-get install --no-install-recommends -yqq apt-transport-https conntrack ca-certificates git ${join(" ", var.apt_packages)}",
    ]
  }

provisioner "remote-exec" {
    inline = [
      "echo '*    soft nofile 1048576' | tee -a /etc/security/limits.conf", 
      "echo '*    hard nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root soft nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root hard nofile 1048576' | tee -a /etc/security/limits.conf",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'session required pam_limits.so' | tee -a  /etc/pam.d/common-session",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'fs.file-max=2097152' | tee -a /etc/sysctl.conf",
      "echo 'fs.nr_open=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe ip_conntrack",
      "echo '1024 65535' | tee -a /proc/sys/net/ipv4/ip_local_port_range",
      "echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.core.somaxconn=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
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
  depends_on = ["scaleway_server.proxy01", "scaleway_server.master"]

  count       = "${var.node_count}"
  name        = "${format("node%02d", count.index + 1)}"
  image       = "${data.scaleway_image.ubuntu.id}"
  bootscript  = "${data.scaleway_bootscript.bootscript.id}"
  type        = "${var.node_type}"
  state       = "running"
  enable_ipv6 = true
  tags        = ["kubernetes", "nodes"]

  connection {
    type                = "ssh"
    host                = "${self.private_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${scaleway_server.proxy01.0.public_ip}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  volume {
    size_in_gb = "${var.node_volume_size}"
    type       = "l_ssd"
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.proxy01.0.private_ip}:8888' | tee -a  /etc/environment",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /var/lib/apt/lists/*",
      "apt-get update -yqq",
      "apt-get install --no-install-recommends -yqq apt-transport-https conntrack ca-certificates ${join(" ", var.apt_packages)}",
    ]
  }

provisioner "remote-exec" {
    inline = [
      "echo '*    soft nofile 1048576' | tee -a /etc/security/limits.conf", 
      "echo '*    hard nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root soft nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root hard nofile 1048576' | tee -a /etc/security/limits.conf",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'session required pam_limits.so' | tee -a  /etc/pam.d/common-session",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'fs.file-max=2097152' | tee -a /etc/sysctl.conf",
      "echo 'fs.nr_open=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe ip_conntrack",
      "echo '1024 65535' | tee -a /proc/sys/net/ipv4/ip_local_port_range",
      "echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.core.somaxconn=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "file" {
    content     = "role: node"
    destination = "/etc/salt/grains"
  }
}