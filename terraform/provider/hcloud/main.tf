##################################################
# proxy01
##################################################
resource "hcloud_network" "private" {
  name = "private"
  ip_range = "10.0.0.0/8"
  labels = {
    app = "kubernetes"
  }
}

resource "hcloud_network_subnet" "kubernetes" {
  network_id = "${hcloud_network.private.id}"
  type = "server"
  network_zone = "eu-central"
  ip_range = "10.0.1.0/24"
}

resource "hcloud_server" "proxy01" {
  count       = 1
  name        = "proxy01"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.proxy_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${file("${format("%s/templates/proxy.user-data", path.module)}")}"
  labels = {
    app = "kubernetes",
    role = "edge router",
    salt = "master",
  }

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
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'http_proxy=http://localhost:3128' | tee -a  /etc/environment",
      "echo 'https_proxy=http://localhost:3128' | tee -a  /etc/environment",
    ]
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
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
    ]
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
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
    ]
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
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
    ]
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
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
    ]
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

resource "hcloud_server_network" "proxy01" {
  count = 1
  server_id = "${hcloud_server.proxy01.id}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "proxy02" {
  count = 1
  server_id = "${hcloud_server.proxy02.id}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "etcd" {
  count = "${var.etcd_count}"
  server_id = "${element(hcloud_server.etcd.*.id, count.index)}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "master" {
  count = "${var.master_count}"
  server_id = "${element(hcloud_server.master.*.id, count.index)}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "node" {
  count = "${var.node_count}"
  server_id = "${element(hcloud_server.node.*.id, count.index)}"
  network_id = "${hcloud_network.private.id}"
}