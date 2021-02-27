resource "null_resource" "proxy-exceptions-quote" {
  count = var.host_count

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
    inline = [
      "echo no_proxy=\\\"localhost,127.0.0.1,.svc,.svc.cluster.local,*cluster.local,${var.service_cidr},${var.overlay_cidr},${var.vpn_iprange}\\\" | tee -a /etc/environment",
    ]
  }
}
