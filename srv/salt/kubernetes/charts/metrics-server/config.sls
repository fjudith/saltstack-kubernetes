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

/srv/kubernetes/charts/metrics-server/values.yaml:
  file.{{ state }}:
    - require:
      - file:  /srv/kubernetes/charts/metrics-server
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  