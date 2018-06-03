variable "etcd_count" {}
variable "master_count" {}
variable "node_count" {}

variable "master_cluster_ip" {
  description = "Kubernetes cluster IP"
  default     = "10.3.0.1"
}

variable "etcd_private_ips" {
  description = "List of Etcd private ip adresses"
  type        = "list"
}

variable "master_private_ips" {
  description = "List of Kubernetes master private ip adresses"
  type        = "list"
}

variable "node_private_ips" {
  description = "List of Node private ip adresses"
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

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl etcd etcd ${join(",", var.etcd_private_ips)}"
  }
}

resource "null_resource" "cert-master" {
  depends_on = ["null_resource.cert-ca"]
  count      = "${var.master_count}"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl master master-${element(var.master_private_ips, count.index)} ${join(",", concat(var.master_private_ips, list(var.master_cluster_ip)))}"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl apiserver kube-apiserver-${element(var.master_private_ips, count.index)} ${join(",", concat(var.master_private_ips, list(var.master_cluster_ip)))}"
  }
}

resource "null_resource" "cert-node" {
  depends_on = ["null_resource.cert-ca"]
  count      = "${var.node_count}"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl node node-${element(var.node_private_ips, count.index)} ${join("," , var.node_private_ips)}"
  }
}

resource "null_resource" "cert-kube-proxy" {
  depends_on = ["null_resource.cert-ca"]
  count      = "${var.master_count + var.node_count}"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl kube-proxy kube-proxy-${element(concat(var.master_private_ips, var.node_private_ips), count.index)} ${join(",", concat(var.master_private_ips, var.node_private_ips))}"
  }
}

resource "null_resource" "cert-flanneld" {
  depends_on = ["null_resource.cert-ca"]
  count      = "${var.master_count + var.node_count}"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "${path.module}/scripts/cfssl.sh ssl flanneld flanneld-${element(concat(var.master_private_ips, var.node_private_ips), count.index)} ${join(",", concat(var.master_private_ips, var.node_private_ips))}"
  }
}
