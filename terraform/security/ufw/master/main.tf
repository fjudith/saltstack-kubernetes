variable "count" {}

variable "bastion_host" {}
variable "overlay_cidr" {}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = "list"
}

variable "private_interface" {
  type = "string"
}

variable "docker_interface" {
  type = "string"
}

variable "vpn_interface" {
  type = "string"
}

variable "vpn_port" {
  type = "string"
}

variable "kubernetes_interface" {
  type = "string"
}

resource "null_resource" "firewall" {
  count = "${var.count}"

  triggers = {
    template = "${data.template_file.ufw.rendered}"
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

  provisioner "file" {
    source = "${path.module}/files/"
    destination = "/etc/ufw/application.d"
  }

  provisioner "remote-exec" {
    inline = <<EOF
${data.template_file.ufw.rendered}
EOF
  }
}

data "template_file" "ufw" {
  template = "${file("${path.module}/scripts/ufw.sh")}"

  vars {
    private_interface    = "${var.private_interface}"
    kubernetes_interface = "${var.kubernetes_interface}"
    vpn_interface        = "${var.vpn_interface}"
    vpn_port             = "${var.vpn_port}"
    docker_interface     = "${var.docker_interface}"
    overlay_cidr         = "${var.overlay_cidr}"
  }
}
