# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kubeadm with context %}
{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set localIpAddress = salt['network.ip_addrs'](pillar['controlPlaneInterface']) -%}

{%- set masters = [] -%}
{%- for key, value in salt['mine.get'](tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

kubernetes-ca:
  file.directory:
    - name: /etc/kubernetes/pki
  x509.pem_managed:
    - name: /etc/kubernetes/pki/ca.crt
    - text: {{ salt['mine.get'](tgt=masters|first, fun='x509.get_pem_entries', tgt_type='glob')[masters|first]['/etc/kubernetes/pki/ca.crt']|replace('\n', '') }}
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
    - contents: {{ salt['mine.get'](tgt=masters|first, fun='file.read', tgt_type='compound').values()|list|yaml }}
    - makedirs: true
  cmd.run:
    - watch:
      - file: /root/.kube/config
    - name: |
        kubectl label node {{ hostname }} node-role.kubernetes.io/node=true --overwrite
        kubectl label node {{ hostname }} role=storage-node --overwrite
        kubectl label node {{ hostname }} node.longhorn.io/create-default-disk=true --overwrite
        kubectl label node {{ hostname }} openebs.io/engine=mayastor --overwrite
