# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import kubeadm with context %}

kubeadm-node-token:
  cmd.run:
    - name: |
       /usr/bin/kubeadm --kubeconfig /etc/kubernetes/admin.conf token delete {{ kubeadm.token }}
       /usr/bin/kubeadm --kubeconfig /etc/kubernetes/admin.conf token create {{ kubeadm.token }}
       /usr/bin/kubeadm --config /root/kubeadm-config.yaml init phase upload-certs --upload-certs