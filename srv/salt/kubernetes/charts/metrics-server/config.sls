# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import metrics_server with context %}

{% set state = 'absent' %}
{% if metrics_server.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/metrics-server:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
  