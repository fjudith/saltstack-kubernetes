# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import concourse with context %}

{% set file_state = 'absent' %}
{% if concourse.enabled -%}
  {% set file_state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/concourse:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/concourse:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
