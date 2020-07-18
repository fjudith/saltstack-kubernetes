# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import etcdadm with context %}
{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set controlPlaneInterface = pillar['controlPlaneInterface'] -%}
{%- set localIpAddress = salt['network.ip_addrs'](controlPlaneInterface) -%}

etcdadm-init:
  cmd.run:
    - require:
      - file: /usr/local/bin/etcdadm
    # - unless: test -f /etc/kubernetes/admin.conf
    - timeout: 300
    - name: |
        /usr/local/bin/etcdadm init --name {{ hostname }} --server-cert-extra-sans {{ localIpAddress[0] }}

send-etcd-ca-certificate:
  module.run:
    - mine.send:
      - name: x509.get_pem_entries 
      - glob_path: /etc/etcd/pki/ca.*
    - watch:
      - cmd: etcdadm-init

{# send-etc-ca-key:
  module.run:
    - mine.send:
      - name: x509.get_pem_entries 
      - glob_path: /etc/etcd/pki/ca.key
    - watch:
      - cmd: etcdadm-init #}