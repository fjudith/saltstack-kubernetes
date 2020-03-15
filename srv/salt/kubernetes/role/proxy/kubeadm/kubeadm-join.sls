# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kubeadm with context %}
{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set localIpAddress = salt['network.ip_addrs'](pillar['controlPlaneInterface']) -%}

kubernetes-ca:
  file.directory:
    - name: /etc/kubernetes/pki
  x509.pem_managed:
    - name: /etc/kubernetes/pki/ca.crt
    - text: {{ salt['mine.get'](tgt='master01', fun='x509.get_pem_entries', tgt_type='glob')['master01']['/etc/kubernetes/pki/ca.crt']|replace('\n', '') }}
    - backup: True

kubeadm-register-node:
  file.managed:
    - watch:
      - x509: /etc/kubernetes/pki/ca.crt
    - name: /root/kubeadm-join-node.yaml
    - source: salt://{{ tpldir }}/templates/kubeadm-node.{{ kubeadm.apiVersion }}.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
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
    - watch:
      - cmd: kubeadm-register-node
    - name: /root/.kube/config
    - contents: {{ salt['mine.get'](tgt='master01', fun='file.read', tgt_type='compound').values()|list|yaml }}
    - makedirs: true
  cmd.run:
    - watch:
      - file: /root/.kube/config
    - name: |
        kubectl label node {{ hostname }} node-role.kubernetes.io/node=true --overwrite
        kubectl label node {{ hostname }} node-role.kubernetes.io/ingress=true --overwrite
        kubectl label node {{ hostname }} rook-edgefs-nodetype=gateway --overwrite