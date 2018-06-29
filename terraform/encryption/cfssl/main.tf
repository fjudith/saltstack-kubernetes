variable "etcd_count" {}
variable "master_count" {}
variable "node_count" {}
variable "bastion_host" {}
variable "domain" {}
variable "cluster_public_dns" {}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "master_cluster_ip" {
  description = "Kubernetes cluster IP"
  default     = "10.3.0.1"
}

variable "etcd_private_ips" {
  description = "List of Etcd private ip adresses"
  type        = "list"
}

variable "etcd_hostnames" {
  description = "List of Etcd hostnames"
  type        = "list"
}

variable "master_private_ips" {
  description = "List of Kubernetes master private ip adresses"
  type        = "list"
}

variable "master_hostnames" {
  description = "List of Kubernetes master hostnames"
  type        = "list"
}

variable "node_private_ips" {
  description = "List of Node private ip adresses"
  type        = "list"
}

variable "node_hostnames" {
  description = "List of Kubernetes node hostnames"
  type        = "list"
}

variable "cert_path" {
  description = "Certificates storage path"
  default     = "ssl"
}

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

resource "null_resource" "cert-admin" {
  depends_on = ["null_resource.cert-ca"]
  count      = "${var.master_count}"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl admin kube-admin"
  }
}

resource "null_resource" "cert-dashboard" {
  depends_on = ["null_resource.cert-ca"]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl dashboard kubernetes-dashboard"
  }
}

resource "null_resource" "cert-etcd" {
  depends_on = ["null_resource.cert-ca"]
  count      = "${var.etcd_count}"

  connection {
    type                = "ssh"
    host                = "${element(var.etcd_private_ips, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/etcd-${element(var.etcd_hostnames, count.index)} etcd etcd-${element(var.etcd_hostnames, count.index)} ${join(",", list(element(var.etcd_hostnames, count.index), element(var.etcd_private_ips, count.index)))}"
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
  depends_on = ["null_resource.cert-ca", "null_resource.cert-dashboard"]
  count      = "${var.master_count}"

  connection {
    type                = "ssh"
    host                = "${element(var.master_private_ips, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} master master-${element(var.master_hostnames, count.index)} ${join(",", concat(var.master_hostnames, var.master_private_ips, list(var.master_cluster_ip), list(var.cluster_public_dns)))}"
  }

  provisioner "file" {
    source      = "ssl/master-${element(var.master_hostnames, count.index)}/master-${element(var.master_hostnames, count.index)}.tar"
    destination = "/tmp/master.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/master-${element(var.master_hostnames, count.index)} apiserver kube-apiserver-${element(var.master_hostnames, count.index)} ${join(",", concat(var.master_hostnames, var.master_private_ips, list(var.master_cluster_ip), list(var.cluster_public_dns)))}"
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

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/kubernetes/ssl",
      "tar -C /etc/kubernetes/ssl -xf /tmp/master.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-apiserver.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kubernetes-dashboard.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/kube-proxy.tar",
      "tar -C /etc/kubernetes/ssl -xf /tmp/flanneld.tar",
      "mv /tmp/ca-key.pem /etc/kubernetes/ssl/",
    ]
  }
}

resource "null_resource" "cert-node" {
  depends_on = ["null_resource.cert-ca"]
  count      = "${var.node_count}"

  connection {
    type                = "ssh"
    host                = "${element(var.node_private_ips, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "1m"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/node-${element(var.node_hostnames, count.index)} node node-${element(var.node_hostnames, count.index)} ${join("," , concat(list(element(var.node_private_ips, count.index), element(var.node_hostnames, count.index))))}"
  }

  provisioner "file" {
    source      = "ssl/node-${element(var.node_hostnames, count.index)}/node-${element(var.node_hostnames, count.index)}.tar"
    destination = "/tmp/node.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/node-${element(var.node_hostnames, count.index)} kube-proxy kube-proxy-${element(var.node_private_ips, count.index)} ${join(",", var.node_private_ips)}"
  }

  provisioner "file" {
    source      = "ssl/node-${element(var.node_hostnames, count.index)}/kube-proxy-${element(var.node_private_ips, count.index)}.tar"
    destination = "/tmp/kube-proxy.tar"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl/node-${element(var.node_hostnames, count.index)} flanneld flanneld-${element(var.node_hostnames, count.index)} ${element(var.node_private_ips, count.index)}"
  }

  provisioner "file" {
    source      = "ssl/node-${element(var.node_hostnames, count.index)}/flanneld-${element(var.node_hostnames, count.index)}.tar"
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
