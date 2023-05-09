# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import keycloak with context %}

{% set state = 'absent' %}
{% if keycloak.enabled -%}
  {% set state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/keycloak:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/keycloak:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/keycloak/scripts:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/keycloak/scripts/kc-clientsecret.sh:
  file.managed:
    - source: salt://{{ tpldir }}/scripts/kc-clientsecret.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}
