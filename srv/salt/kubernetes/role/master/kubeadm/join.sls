# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import kubeadm with context %}

include:
  - kubernetes.role.master.kubeadm.osprep
  - kubernetes.role.master.kubeadm.repo
  - kubernetes.role.master.kubeadm.install
  - kubernetes.role.master.kubeadm.audit-policy
  - kubernetes.role.master.kubeadm.encryption

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
    - require:
      - pkg: kubelet
      - pkg: kubectl
      - pkg: kubeadm
    - timeout: 600
    - name: |
        /usr/bin/kubeadm join --config /root/kubeadm-controlplane.yaml --ignore-preflight-errors=all

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
      - cmd: kubeadm-init
    - target: /etc/kubernetes/admin.conf
    - user: root
    - group: root
    - mode: 444
    - force: true