# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import kubeadm with context %}

{%- set masters = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:master", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do masters.append(value) -%}
{%- endfor -%}

include:
  - .osprep
  - .repo
  - .install
  - .audit-policy
  - .encryption
  {%- if kubeadm.etcd.external %}
  - .external-etcd-cert
  {%- endif %}
  {%- if grains['id'] == masters|first %}
  - .kubeadm-init
  {% else %}
  - .kubeadm-join
  {%- endif %}