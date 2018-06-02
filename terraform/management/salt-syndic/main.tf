##################################################
# Salt Minion
##################################################
variable "count" {}

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

variable "salt_master_host" {}

resource "null_resource" "salt-minion" {
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
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content = <<EOF
open_mode: True
auto_accept: True
EOF

    destination = "/etc/salt/master.d/auto-accept.conf"
  }

  provisioner "file" {
    content     = "syndic_master: ${var.salt_master_host}"
    destination = "/etc/salt/master.d/syndic_master.conf"
  }

  provisioner "file" {
    content     = "master: localhost"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
      "systemctl restart salt-master",
      "systemctl restart salt-syndic",
    ]
  }
}
