# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import argo with context %}

{% set file_state = 'absent' %}
{% if argo.enabled -%}
  {% set file_state = 'managed' -%}
{% endif %}

/srv/kubernetes/charts/argo:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/argo:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

{%- if argo.cd.oauth.get('keycloak', {'enabled': False}).enabled
    or argo.worklows.oauth.get('keycloak', {'enabled': False}).enabled  %}
/srv/kubernetes/manifests/argo/oauth/keycloak:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
{% endif %}

{%- if argo.workflows.oauth.get('keycloak', {'enabled': False}).enabled %}
argo-workflows-keycloak-secret:
  file.{{ file_state }}:
    - require:
      - file: /srv/kubernetes/manifests/argo/oauth/keycloak
    - name: /srv/kubernetes/manifests/argo/oauth/keycloak/workflows-secret.yaml
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/workflows-secret.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - whatch:
        - file: /srv/kubernetes/manifests/argo/oauth/keycloak/workflows-secret.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/argo/oauth/keycloak/workflows-secret.yaml
{%- endif %}
