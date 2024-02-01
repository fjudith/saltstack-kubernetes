# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import coredns with context %}

{% set state = 'absent' %}
{% if coredns.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/coredns:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/charts/coredns/values.yaml:
  file.{{ state }}:
    - require:
      - file:  /srv/kubernetes/charts/coredns
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  