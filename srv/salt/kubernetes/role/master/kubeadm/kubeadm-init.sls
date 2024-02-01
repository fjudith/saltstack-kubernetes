# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kubeadm with context %}

kubeadm-init:
  file.managed:
    - name: /root/kubeadm-config.yaml
    - source: salt://{{ tpldir }}/templates/kubeadm-config.{{ kubeadm.apiVersion }}.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /root/kubeadm-config.yaml
    - require:
      - pkg: kubelet
      - pkg: kubectl
      - pkg: kubeadm
    - unless: test -f /etc/kubernetes/admin.conf
    - timeout: 300
    - name: |
        /usr/bin/kubeadm init --config /root/kubeadm-config.yaml --ignore-preflight-errors=all --upload-certs --v=5 \
        || /usr/bin/kubeadm reset -f --cert-dir /etc/kubernetes/pki
    - require_in:
      - sls: kubernetes.role.master.kubeadm.join
      - sls: kubernetes.role.node.kubeadm.join
      - sls: kubernetes.role.proxy.kubeadm.join

/root/.kube:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/root/.kube/config:
  file.symlink:
    - require:
      - file: /root/.kube
    - watch:
      - cmd: kubeadm-init
    - target: /etc/kubernetes/admin.conf
    - user: root
    - group: root
    - mode: "0444"
    - force: true

send-ca-certificate:
  module.run:
    - mine.send:
      - name: x509.get_pem_entries 
      - glob_path: /etc/kubernetes/pki/ca.crt
    - watch:
      - cmd: kubeadm-init

send-kubeconfig:
  module.run:
    - mine.send:
      - name: file.read
      - path: /etc/kubernetes/admin.conf
    - watch:
      - cmd: kubeadm-init