# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set localIpAddress = salt['network.ip_addrs'](pillar['controlPlaneInterface']) -%}
{%- from "kubernetes/role/node/kubeadm/map.jinja" import kubeadm with context %}

include:
  - kubernetes.role.node.kubeadm.osprep
  - kubernetes.role.node.kubeadm.repo
  - kubernetes.role.node.kubeadm.install

kubernetes-ca:
  file.directory:
    - name: /etc/kubernetes/pki
  x509.pem_managed:
    - name: /etc/kubernetes/pki/ca.crt
    - text: {{ salt['mine.get'](tgt='master01', fun='x509.get_pem_entries', tgt_type='glob')['master01']['/etc/kubernetes/pki/ca.crt']|replace('\n', '') }}
    - backup: True

kubeadm-register-node:
  file.managed:
    - name: /root/kubeadm-join-node.yaml
    - source: salt://kubernetes/role/node/kubeadm/templates/kubeadm-node.{{ kubeadm.apiVersion }}.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - x509: /etc/kubernetes/pki/ca.crt
  cmd.run:
    - require:
      - pkg: kubelet
      - pkg: kubectl
      - pkg: kubeadm
    - timeout: 300
    - name: |
        /usr/bin/kubeadm join --config /root/kubeadm-join-node.yaml --ignore-preflight-errors=all --v=5

kubectl-label-node:
  file.managed:
    - name: /root/.kube/config
    - contents: |
        {{ salt['mine.get'](tgt='master01', fun='file.read', tgt_type='glob') }}
        {# {%- for item in salt['mine.get'](tgt='master01', fun='file.read', tgt_type='glob')['master01'] %}
        {{ item }}
        {%- endfor %} #}
    - makedirs: true
  cmd.run:
    - name: |
        kubectl label node {{ hostname }} node-role.kubernetes.io/node=true --overwrite
