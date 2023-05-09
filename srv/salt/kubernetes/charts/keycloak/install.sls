# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import keycloak with context %}

{% set state = 'absent' %}
{% set file_state = 'absent' %}
{% if keycloak.enabled %}
  {% set state = 'present' %}
  {% set file_state = 'managed' %}
{% endif %}

keycloak:
  file.{{ file_state }}:
    - require:
      - file:  /srv/kubernetes/charts/keycloak
    - name: /srv/kubernetes/charts/keycloak/values.yaml
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
  helm.release_{{ state }}:
    - watch:
      - file: /srv/kubernetes/charts/keycloak/values.yaml
    - name: keycloak
    {%- if keycloak.enabled %}
    - chart: bitnami/keycloak
    - values: /srv/kubernetes/charts/keycloak/values.yaml
    - version: {{ keycloak.chart_version }}
    - flags:
      - create-namespace
    {%- endif %}
    - namespace: keycloak
