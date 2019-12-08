# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- set localIpAddress = salt['network.ip_addrs'](pillar['controlPlaneInterface']) -%}
{%- from "kubernetes/role/master/kubeadm/map.jinja" import kubeadm with context %}

include:
  - kubernetes.role.master.kubeadm.osprep
  - kubernetes.role.master.kubeadm.repo
  - kubernetes.role.master.kubeadm.install
  - kubernetes.role.master.kubeadm.audit-policy
  - kubernetes.role.master.kubeadm.encryption

kubeadm-reset:
  cmd.run:
    - only_if: ls /etc/kubernetes/manifests/kube-apiserver.yaml
    - require:
      - pkg: kubeadm
    - timeout: 300
    - name: |
        /usr/bin/kubeadm reset -f --cert-dir /etc/kubernetes/pki      


kubeadm-join:
  file.managed:
    - name: /root/kubeadm-controlplane.yaml
    - source: salt://kubernetes/role/master/kubeadm/templates/kubeadm-controlplane.{{ kubeadm.apiVersion }}.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - watch: 
      - file: /root/kubeadm-controlplane.yaml
      - cmd: kubeadm-reset
    - require:
      - pkg: kubelet
      - pkg: kubectl
      - pkg: kubeadm
    - timeout: 300
    - name: |
        /usr/bin/kubeadm join --config /root/kubeadm-controlplane.yaml --ignore-preflight-errors=all --v=5

/root/.kube:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/root/.kube/config:
  file.symlink:
    - require:
      - file: /root/.kube
    - watch:
      - cmd: kubeadm-join
    - target: /etc/kubernetes/admin.conf
    - user: root
    - group: root
    - mode: 444
    - force: true