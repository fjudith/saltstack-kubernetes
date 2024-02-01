# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import spinnaker with context %}

{% set state = 'absent' %}
{% if spinnaker.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/spinnaker:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
