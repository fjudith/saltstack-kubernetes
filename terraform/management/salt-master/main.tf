##################################################
# Salt Minion
##################################################
resource "null_resource" "salt-master" {
  count = var.count

  connection {
    type                = "ssh"
    host                = element(var.connections, count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
    timeout             = "1m"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-master.sh"
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
    content     = element(data.template_file.master-conf.*.rendered, count.index)
    destination = "/etc/salt/minion.d/master.conf"
  }

  # Copy "salt" and "pillar" data into the salt syndic hosts
  provisioner "file" {
    source      = "../srv/"
    destination = "/srv"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
      "systemctl restart salt-master",
      "systemctl restart salt-master",
    ]
  }
}

data "template_file" "master-conf" {
  count    = var.master_count
  template = file("${path.module}/templates/master.conf")
  vars = {
    salt_master_host     = var.salt_master_host
  }
}