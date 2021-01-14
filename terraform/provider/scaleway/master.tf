##################################################
# Kubernetes Master
##################################################
resource "scaleway_server" "master" {
  depends_on = [scaleway_server.edge01, scaleway_server.etcd]

  count      = var.master_count
  name       = format("master%02d", count.index + 1)
  image      = data.scaleway_image.ubuntu.id
  bootscript = data.scaleway_bootscript.bootscript.id
  type       = var.master_type

  #public_ip = "${element(scaleway_ip.public_ip.*.ip, count.index)}"
  state       = "running"
  enable_ipv6 = true
  tags        = ["kubernetes", "master"]

  connection {
    type                = "ssh"
    host                = self.private_ip
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = scaleway_server.edge01.0.public_ip
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
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
      "echo 'http_edge=http://${scaleway_server.edge01.0.private_ip}:8888' | tee -a  /etc/environment",
      "echo 'https_proxy=http://${scaleway_server.edge01.0.private_ip}:8888' | tee -a  /etc/environment",
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