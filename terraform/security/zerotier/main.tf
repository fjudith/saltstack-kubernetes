##################################################
# Zero tiers MeshVPN
# https://github.com/cormacrelf/terraform-provider-zerotier
##################################################
variable "count" {}

variable "bit" {}

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

variable "zerotier_api_key" {
  description = "Zerotier MeshVPN API key"
  default     = "01234567890123456789012345678901"
}

variable "zerotier_cidr" {
  description = "Zerotier MeshVPN subnet CIDR"
  default     = "172.16.4.0/24"
}

provider "zerotier" {
  api_key = "${var.zerotier_api_key}"
  version = "~>0.0"
}

resource "zerotier_network" "kubernetes" {
  name = "kubernetes"

  # auto-assign v4 addresses to devices
  assignment_pool {
    cidr = "${var.zerotier_cidr}"
  }

  # route requests to the cidr block on each device through zerotier
  route {
    target = "${var.zerotier_cidr}"
  }
}

resource "null_resource" "zerotier" {
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
    source      = "${path.module}/scripts/zerotier.sh"
    destination = "/tmp/zerotier.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/zerotier.sh",
      "/tmp/zerotier.sh ${var.zerotier_api_key} ${zerotier_network.kubernetes.id} ${cidrhost(var.zerotier_cidr, var.bit + count.index + 1)}",
    ]
  }
}

output "api_key" {
  value = "${var.zerotier_api_key}"
}

output "cidr" {
  value = "${var.zerotier_cidr}"
}

# output "network_id" {
#   value = "${zerotier_network.kubernetes.id}"
# }

