# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- set localIpAddress = salt['network.ip_addrs'](pillar['controlPlaneInterface']) -%}
{%- from "kubernetes/role/node/kubeadm/map.jinja" import kubeadm with context %}

include:
  - kubernetes.role.master.kubeadm.osprep
  - kubernetes.role.master.kubeadm.repo
  - kubernetes.role.master.kubeadm.install

/srv/kubernetes/pki/ca.crt:
  file.managed:
    - name: salt://minionfs/ca.crt
    - user: root
    - group: root
    - mode: 644

kubeadm-join:
  file.managed:
    - name: /root/kubeadm-join-node.yaml
    - source: salt://kubernetes/role/node/kubeadm/templates/kubeadm-node.{{ kubeadm.apiVersion }}.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - watch: 
      - file: /root/kubeadm-join-node.yaml
    - require:
      - pkg: kubelet
      - pkg: kubectl
      - pkg: kubeadm
    - timeout: 300
    - name: |
        /usr/bin/kubeadm --config /root/kubeadm-join-node.yaml --ignore-preflight-errors=all --v=5