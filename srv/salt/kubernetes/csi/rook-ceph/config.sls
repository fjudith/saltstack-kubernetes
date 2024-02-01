# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import rook_ceph with context %}

{% set state = 'absent' %}
{% if rook_ceph.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/rook-ceph:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/rook-ceph:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
