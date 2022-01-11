resource "null_resource" "cert-ca" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "mkdir -p ssl"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl ca kube-ca"
  }
}

resource "null_resource" "cert-kube-aggregator-ca" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "mkdir -p ssl"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl kube-aggregator-ca kube-aggregator-ca"
  }
}

resource "null_resource" "cert-etcd-ca" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "mkdir -p ssl"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl etcd-ca etcd-ca"
  }
}

resource "null_resource" "cert-admin" {
  depends_on = [null_resource.cert-ca]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl admin kube-admin"
  }
}

resource "null_resource" "cert-dashboard" {
  depends_on = [null_resource.cert-ca]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl dashboard kubernetes-dashboard"
  }
}

resource "null_resource" "cert-controller-manager" {
  depends_on = [null_resource.cert-ca]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl kube-controller-manager kube-controller-manager"
  }
}

resource "null_resource" "cert-scheduler" {
  depends_on = [null_resource.cert-ca]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl kube-scheduler kube-scheduler"
  }
}

resource "null_resource" "cert-service-account" {
  depends_on = [null_resource.cert-ca]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl service-account service-account"
  }
}

resource "null_resource" "cert-etcd" {
  depends_on = [null_resource.cert-etcd-ca]
  count      = var.etcd_count

  connection {
    type                = "ssh"
    host                = element(var.etcd_private_ips, count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
    timeout             = "1m"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/etcd-${element(var.etcd_hostnames, count.index)} etcd etcd-${element(var.etcd_hostnames, count.index)} ${join(",", tolist([element(var.etcd_hostnames, count.index), element(var.etcd_private_ips, count.index)]))}"
  }

  provisioner "file" {
    source      = "ssl/etcd-${element(var.etcd_hostnames, count.index)}/etcd-${element(var.etcd_hostnames, count.index)}.tar"
    destination = "/tmp/etcd.tar"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/etcd/ssl",
      "tar -C /etc/etcd/ssl -xf /tmp/etcd.tar",
    ]
  }
}

resource "null_resource" "cert-master" {
  depends_on = [null_resource.cert-ca, null_resource.cert-etcd-ca, null_resource.cert-kube-aggregator-ca, null_resource.cert-dashboard]
  count      = var.master_count

  connection {
    type                = "ssh"
    host                = element(var.master_private_ips, count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
    timeout             = "1m"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} master master-${element(var.master_hostnames, count.index)} ${join(",", concat(var.master_hostnames, var.master_private_ips, tolist([var.master_cluster_ip]), tolist([var.cluster_public_dns])))}"
  }

  provisioner "file" {
    source      = "ssl/master-${element(var.master_hostnames, count.index)}/master-${element(var.master_hostnames, count.index)}.tar"
    destination = "/tmp/master.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} apiserver kube-apiserver-${element(var.master_hostnames, count.index)} ${join(",", concat(var.master_hostnames, var.master_private_ips, tolist([var.master_cluster_ip]), tolist([var.cluster_public_dns])))}"
  }

  provisioner "file" {
    source      = "ssl/master-${element(var.master_hostnames, count.index)}/kube-apiserver-${element(var.master_hostnames, count.index)}.tar"
    destination = "/tmp/kube-apiserver.tar"
  }

  provisioner "file" {
    source      = "ssl/kubernetes-dashboard.tar"
    destination = "/tmp/kubernetes-dashboard.tar"
  }

  provisioner "file" {
    source      = "ssl/kube-controller-manager.tar"
    destination = "/tmp/kube-controller-manager.tar"
  }

  provisioner "file" {
    source      = "ssl/kube-scheduler.tar"
    destination = "/tmp/kube-scheduler.tar"
  }

  provisioner "file" {
    source      = "ssl/service-account.tar"
    destination = "/tmp/service-account.tar"
  }

  provisioner "file" {
    source      = "ssl/ca-key.pem"
    destination = "/tmp/ca-key.pem"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} kube-proxy kube-proxy-${element(var.master_private_ips, count.index)} ${join(",", var.master_private_ips)}"
  }

  provisioner "file" {
    source      = "ssl/master-${element(var.master_hostnames, count.index)}/kube-proxy-${element(var.master_private_ips, count.index)}.tar"
    destination = "/tmp/kube-proxy.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} flanneld flanneld-${element(var.master_hostnames, count.index)} ${element(var.master_private_ips, count.index)}"
  }

  provisioner "file" {
    source      = "ssl/master-${element(var.master_hostnames, count.index)}/flanneld-${element(var.master_hostnames, count.index)}.tar"
    destination = "/tmp/flanneld.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} kube-aggregator-client kube-aggregator-client-${element(var.master_hostnames, count.index)}"
  }

  provisioner "file" {
    source      = "ssl/master-${element(var.master_hostnames, count.index)}/kube-aggregator-client-${element(var.master_hostnames, count.index)}.tar"
    destination = "/tmp/kube-aggregator-client.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} etcd-client kube-apiserver-etcd-client-${element(var.master_hostnames, count.index)} ${join(",", concat(var.master_hostnames, var.master_private_ips, tolist([var.master_cluster_ip]), tolist([var.cluster_public_dns])))}"
  }

  provisioner "file" {
    source      = "ssl/master-${element(var.master_hostnames, count.index)}/kube-apiserver-etcd-client-${element(var.master_hostnames, count.index)}.tar"
    destination = "/tmp/kube-apiserver-etcd-client.tar"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/kubernetes/ssl",
      "tar -C /etc/kubernetes/ssl -xf /tmp/master.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-apiserver.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kubernetes-dashboard.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-proxy.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/flanneld.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-controller-manager.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-scheduler.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/service-account.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-aggregator-client.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-apiserver-etcd-client.tar",
      "mv /tmp/ca-key.pem /etc/kubernetes/ssl/",
    ]
  }
}

resource "null_resource" "cert-node" {
  depends_on = [null_resource.cert-ca]
  count      = var.edge_count + var.node_count

  connection {
    type                = "ssh"
    host                = element(concat(var.edge_private_ips, var.node_private_ips), count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
    timeout             = "1m"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)} node node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)} ${join("," , concat(tolist([element(concat(var.edge_private_ips, var.node_private_ips), count.index), element(concat(var.edge_hostnames, var.node_hostnames), count.index)])))}"
  }

  provisioner "file" {
    source      = "ssl/node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)}/node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)}.tar"
    destination = "/tmp/node.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)} kube-proxy kube-proxy-${element(concat(var.edge_private_ips, var.node_private_ips), count.index)} ${join(",", concat(var.edge_private_ips, var.node_private_ips))}"
  }

  provisioner "file" {
    source      = "ssl/node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)}/kube-proxy-${element(concat(var.edge_private_ips, var.node_private_ips), count.index)}.tar"
    destination = "/tmp/kube-proxy.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)} flanneld flanneld-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)} ${element(concat(var.edge_private_ips, var.node_private_ips), count.index)}"
  }

  provisioner "file" {
    source      = "ssl/node-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)}/flanneld-${element(concat(var.edge_hostnames, var.node_hostnames), count.index)}.tar"
    destination = "/tmp/flanneld.tar"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/kubernetes/ssl",
      "tar -C /etc/kubernetes/ssl -xf /tmp/node.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-proxy.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/flanneld.tar",
    ]
  }
}
