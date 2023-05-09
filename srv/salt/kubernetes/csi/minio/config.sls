# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import minio with context %}

{% set state = 'absent' %}
{% if minio.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/minio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/minio:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
