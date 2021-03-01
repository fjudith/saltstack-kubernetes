# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import harbor with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

harbor-configure-oidc:
  file.managed:
    - watch:
      - cmd: harbor
    - name: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/auth-oidc.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - http: query-harbor-core
    - watch:
      - file: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - runas: root
    - name: |
        http --auth "admin:{{ harbor.adminPassword }}" PUT https://{{ harbor.coreIngressHost }}.{{ public_domain }}/api/v2.0/configurations < /srv/kubernetes/manifests/harbor/auth-oidc.json