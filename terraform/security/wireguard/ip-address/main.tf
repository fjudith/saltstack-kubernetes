variable "vpn_iprange" {}
variable "count" {}

variable "address_bit" {}

variable "bastion_host" {}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = "list"
}

resource "null_resource" "wireguard-ip" {
  count = "${var.count}"

  connection {
    type                = "ssh"
    host                = "${element(var.connections, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = <<EOF
${data.template_file.update-wg-ip.rendered}
EOF
  }
}

data "template_file" "update-wg-ip" {
  template = "${file("${path.module}/scripts/update-wg-ip.sh")}"

  vars {
    ipaddress = "${cidrhost(var.vpn_iprange, var.bit + count.index + 1)}"
  }
}
