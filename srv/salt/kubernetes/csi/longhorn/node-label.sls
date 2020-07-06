# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openebs with context %}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- set nodes = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:node", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do nodes.append(value) -%}
{%- endfor -%}

{%- for node in nodes %}
{%- for file in storage.loopback_iscsi.files %}
longhorn-label-{{ node }}:
  cmd.run:
    - user: root
    - name: |
        kubectl label node {{ node }} node.longhorn.io/create-default-disk=config --overwrite

longhorn-annotation-{{ node }}:
  cmd.run:
    - user: root
    - name: |
        kubectl annotate node {{ node }} node.longhorn.io/default-disks-config='[{% for file in loopback_iscsi.files %}{"path":"/mnt/{{ file.lun_name }}","allowScheduling":true,"tags"["loopback-isci"]}{% if not loop.last %},{% endif %}{% endfor %}]' --overwrite
{%- endfor %}
{%- endfor %}


