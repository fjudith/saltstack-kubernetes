variable "count" {}

variable "proxy_count" {}

variable "etcd_count" {}

variable "master_count" {}

variable "node_count" {}

variable "bastion_host" {}

variable "proxy_bit" {
  default = 250
}

variable "etcd_bit" {
  default = 50
}

variable "master_bit" {
  default = 100
}

variable "node_bit" {
  default = 200
}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = "list"
}

variable "private_ips" {
  type = "list"
}

variable "vpn_interface" {
  default = "wg0"
}

variable "vpn_port" {
  default = "51820"
}

variable "hostnames" {
  type = "list"
}

variable "overlay_cidr" {
  type = "string"
}

variable "vpn_iprange" {
  default = "172.16.4.0/24"
}

variable "vpn_ipv6range" {
  default = "fd86:ea04:1115::/64"
}

resource "null_resource" "wireguard" {
  count = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"

  triggers {
    count = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"
  }

  connection {
    type                = "ssh"
    host                = "${element(var.connections, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf",
      "echo net.ipv6.conf.all.forwarding=1 >> /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get install -yq libmnl-dev libelf-dev pkg-config software-properties-common build-essential",
      "add-apt-repository -y ppa:wireguard/wireguard",
      "apt-get update",
    ]
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/install-kernel-headers.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt-get install -yq wireguard-dkms wireguard-tools",
    ]
  }

  provisioner "file" {
    content     = "${element(data.template_file.interface-conf.*.rendered, count.index)}"
    destination = "/etc/wireguard/${var.vpn_interface}.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 700 /etc/wireguard/${var.vpn_interface}.conf",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "${join("\n", formatlist("echo '%s %s' >> /etc/hosts", data.template_file.vpn_ips.*.rendered, var.hostnames))}",
      "systemctl is-enabled wg-quick@${var.vpn_interface} || systemctl enable wg-quick@${var.vpn_interface}",
      "systemctl restart wg-quick@${var.vpn_interface}",
    ]
  }

  provisioner "file" {
    content     = "${element(data.template_file.overlay-route-service.*.rendered, count.index)}"
    destination = "/etc/systemd/system/overlay-route.service"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl start overlay-route.service",
      "systemctl is-enabled overlay-route.service || systemctl enable overlay-route.service",
    ]
  }
}

data "template_file" "interface-conf" {
  count    = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"
  template = "${file("${path.module}/templates/interface.conf")}"

  vars {
    address     = "${element(data.template_file.vpn_ips.*.rendered, count.index)}"
    addressv6   = "${element(data.template_file.vpn_ipv6s.*.rendered, count.index)}"
    port        = "${var.vpn_port}"
    private_key = "${element(data.external.keys.*.result.private_key, count.index)}"
    peers       = "${replace(join("\n", data.template_file.peer-conf.*.rendered), element(data.template_file.peer-conf.*.rendered, count.index), "")}"
  }
}

data "template_file" "peer-conf" {
  count    = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"
  template = "${file("${path.module}/templates/peer.conf")}"

  vars {
    endpoint   = "${element(var.private_ips, count.index)}"
    port       = "${var.vpn_port}"
    public_key = "${element(data.external.keys.*.result.public_key, count.index)}"

    allowed_ips = "${element(data.template_file.vpn_ips.*.rendered, count.index)}/32,${element(data.template_file.vpn_ipv6s.*.rendered, count.index)}/128"

    #allowed_ips = "${join(",",list(join("/",list(element(data.template_file.vpn_ips.*.rendered, count.index),"32"),join("/",list(element(data.template_file.vpn_ipv6s.*.rendered, count.index),"64")))))}"
  }
}

data "template_file" "overlay-route-service" {
  count    = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"
  template = "${file("${path.module}/templates/overlay-route.service")}"

  vars {
    address      = "${element(data.template_file.vpn_ips.*.rendered, count.index)}"
    overlay_cidr = "${var.overlay_cidr}"
  }
}

data "external" "keys" {
  count = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"

  program = ["sh", "${path.module}/scripts/gen_keys.sh"]
}

data "template_file" "proxy_vpn_ips" {
  count    = "${var.proxy_count}"
  template = "$${ip}"

  vars {
    ip = "${cidrhost(var.vpn_iprange, var.proxy_bit + count.index + 1)}"
  }
}

data "template_file" "proxy_vpn_ipv6s" {
  count    = "${var.proxy_count}"
  template = "$${ipv6}"

  vars {
    ipv6 = "${cidrhost(var.vpn_ipv6range, var.proxy_bit + count.index + 1)}"
  }
}

data "template_file" "etcd_vpn_ips" {
  count    = "${var.etcd_count}"
  template = "$${ip}"

  vars {
    ip = "${cidrhost(var.vpn_iprange, var.etcd_bit + count.index + 1)}"
  }
}

data "template_file" "etcd_vpn_ipv6s" {
  count    = "${var.etcd_count}"
  template = "$${ipv6}"

  vars {
    ipv6 = "${cidrhost(var.vpn_ipv6range, var.etcd_bit + count.index + 1)}"
  }
}

data "template_file" "master_vpn_ips" {
  count    = "${var.master_count}"
  template = "$${ip}"

  vars {
    ip = "${cidrhost(var.vpn_iprange, var.master_bit + count.index + 1)}"
  }
}

data "template_file" "master_vpn_ipv6s" {
  count    = "${var.master_count}"
  template = "$${ipv6}"

  vars {
    ipv6 = "${cidrhost(var.vpn_ipv6range, var.master_bit + count.index + 1)}"
  }
}

data "template_file" "node_vpn_ips" {
  count    = "${var.node_count}"
  template = "$${ip}"

  vars {
    ip = "${cidrhost(var.vpn_iprange, var.node_bit + count.index + 1)}"
  }
}

data "template_file" "node_vpn_ipv6s" {
  count    = "${var.node_count}"
  template = "$${ipv6}"

  vars {
    ipv6 = "${cidrhost(var.vpn_ipv6range, var.node_bit + count.index + 1)}"
  }
}

data "template_file" "vpn_ips" {
  count    = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"
  template = "$${ip}"

  vars {
    ip = "${element(concat(data.template_file.proxy_vpn_ips.*.rendered, data.template_file.etcd_vpn_ips.*.rendered, data.template_file.master_vpn_ips.*.rendered, data.template_file.node_vpn_ips.*.rendered), count.index)}"
  }
}

data "template_file" "vpn_ipv6s" {
  count    = "${var.proxy_count + var.etcd_count + var.master_count + var.node_count }"
  template = "$${ipv6}"

  vars {
    ipv6 = "${element(concat(data.template_file.proxy_vpn_ipv6s.*.rendered, data.template_file.etcd_vpn_ipv6s.*.rendered, data.template_file.master_vpn_ipv6s.*.rendered, data.template_file.node_vpn_ipv6s.*.rendered), count.index)}"
  }
}

output "gateway_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.proxy_vpn_ips.0.rendered}"]
}

output "proxy_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.proxy_vpn_ips.*.rendered}"]
}

output "etcd_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.etcd_vpn_ips.*.rendered}"]
}

output "master_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.master_vpn_ips.*.rendered}"]
}

output "node_vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.node_vpn_ips.*.rendered}"]
}

output "vpn_ips" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.vpn_ips.*.rendered}"]
}

output "proxy_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.proxy_vpn_ipv6s.*.rendered}"]
}

output "etcd_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.etcd_vpn_ipv6s.*.rendered}"]
}

output "master_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.master_vpn_ipv6s.*.rendered}"]
}

output "node_vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.node_vpn_ipv6s.*.rendered}"]
}

output "vpn_ipv6s" {
  depends_on = ["null_resource.wireguard"]
  value      = ["${data.template_file.vpn_ipv6s.*.rendered}"]
}

output "vpn_unit" {
  depends_on = ["null_resource.wireguard"]
  value      = "wg-quick@${var.vpn_interface}.service"
}

output "vpn_interface" {
  value = "${var.vpn_interface}"
}

output "vpn_port" {
  value = "${var.vpn_port}"
}

output "overlay_cidr" {
  value = "${var.overlay_cidr}"
}
