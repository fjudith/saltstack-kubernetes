# -*- coding: utf-8 -*-
# vim: ft=jinja

include:
  - kubernetes.role.node.kubeadm.osprep
  - kubernetes.role.node.kubeadm.repo
  - kubernetes.role.node.kubeadm.install
  - kubernetes.role.node.kubeadm.join
