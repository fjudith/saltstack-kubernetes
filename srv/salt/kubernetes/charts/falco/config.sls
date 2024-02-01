# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import falco with context %}

{% set state = 'absent' %}
{% if falco.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/falco:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
  