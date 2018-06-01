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

  provisioner "file" {
    source      = "${path.module}/scripts/salt-minion.sh"
    destination = "/tmp/salt-minion.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/salt-minion.sh",
      "/tmp/salt-minion.sh",
    ]
  }

  provisioner "file" {
    content     = "master: ${var.salt_master_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }
}
