# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import etcdadm with context %}
{%- set hostname = salt['grains.get']('fqdn') -%}
{%- set controlPlaneInterface = pillar['controlPlaneInterface'] -%}
{%- set localIpAddress = salt['network.ip_addrs'](controlPlaneInterface) -%}

{%- set etcds = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:etcd", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do etcds.append(value) -%}
{%- endfor -%}

etcd-ca-certificate:
  x509.pem_managed:
    - require:
      - file: /etc/etcd/pki
    - name: /etc/etcd/pki/ca.crt
    - text: {{ salt['mine.get'](tgt=etcds|first, fun='x509.get_pem_entries', tgt_type='glob')[etcds|first]['/etc/etcd/pki/ca.crt']|replace('\n', '') }}
    - backup: True

etcd-ca-key:
  x509.pem_managed:
    - require:
      - file: /etc/etcd/pki
    - name: /etc/etcd/pki/ca.key
    - text: {{ salt['mine.get'](tgt=etcds|first, fun='x509.get_pem_entries', tgt_type='glob')[etcds|first]['/etc/etcd/pki/ca.key']|replace('\n', '') }}
    - backup: True

etcdadm-join:
  cmd.run:
    - require:
      - file: /usr/local/bin/etcdadm
      - x509: etcd-ca-certificate
      - x509: etcd-ca-key
    # - unless: test -f /etc/kubernetes/admin.conf
    - timeout: 300
    - name: |
        /usr/local/bin/etcdadm join https://{{ etcds|first }}:2379 --name {{ hostname }} --server-cert-extra-sans {{ localIpAddress[0] }}