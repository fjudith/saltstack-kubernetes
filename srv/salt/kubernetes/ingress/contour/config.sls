# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import contour with context %}

{% set state = 'absent' %}
{% if contour.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/contour:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/charts/contour/values.yaml:
  file.{{ state }}:
    - require:
      - file:  /srv/kubernetes/charts/contour
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/contour:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True