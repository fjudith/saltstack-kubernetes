# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import cert_manager with context %}

{% set state = 'absent' %}
{% if cert_manager.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/cert-manager:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
 
/srv/kubernetes/manifests/cert-manager:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
