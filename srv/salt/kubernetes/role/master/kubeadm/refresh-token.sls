# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from "kubernetes/role/master/kubeadm/map.jinja" import kubeadm with context %}

kubeadm-node-token:
  cmd.run:
    - watch:
      - cmd: kubeadm-init
    - require:
      - pkg: kubeadm
    - name: |
       /usr/bin/kubeadm --kubeconfig /etc/kubernetes/admin.conf token delete "{{ kubeadm.token }}"
       /usr/bin/kubeadm --kubeconfig /etc/kubernetes/admin.conf token create "{{ kubeadm.token }}"