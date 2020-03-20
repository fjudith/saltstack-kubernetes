##################################################
# Kubernetes Master
##################################################
resource "hcloud_server" "master" {
  depends_on = ["hcloud_server.edge01", "hcloud_server.etcd"]

  count       = "${var.master_count}"
  name        = "${format("master%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.master_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${data.template_file.master_cloud-init.rendered}"
  labels = {
    app  = "kubernetes"
    role = "master"
    salt = "minion"
  }

  connection {
    type                = "ssh"
    host                = "${self.ipv4_address}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${hcloud_server.edge01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --long --wait",
    ]
  }
}