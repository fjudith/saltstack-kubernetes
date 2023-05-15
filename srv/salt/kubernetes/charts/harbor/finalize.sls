# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import harbor with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

harbor-oidc:
  http.wait_for_successful_query:
    - name: https://{{ harbor.ingress.host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200
  file.managed:
    - watch:
      - helm: harbor
    - name: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - source: salt://{{ tpldir }}/templates/auth-oidc.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - http: https://{{ harbor.ingress.host }}.{{ public_domain }}
    - require:
      - file: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - runas: root
    - name: |
        http --auth "admin:{{ harbor.admin_password }}" PUT https://{{ harbor.ingress.host }}.{{ public_domain }}/api/v2.0/configurations < /srv/kubernetes/manifests/harbor/auth-oidc.json

