# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import harbor with context %}

{% set state = 'absent' %}
{% if harbor.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/harbor:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/harbor:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
