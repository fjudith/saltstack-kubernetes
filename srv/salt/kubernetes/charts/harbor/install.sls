# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import harbor with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

harbor:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - watch:
        - cmd: harbor-namespace
        - cmd: harbor-fetch-charts
        - file: /srv/kubernetes/manifests/harbor/values.yaml
    - cwd: /srv/kubernetes/manifests/harbor/harbor
    - use_vt: true
    - name: |
        helm dependency update
        helm upgrade --install harbor \
          --namespace harbor \
          --values /srv/kubernetes/manifests/harbor/values.yaml \
          "./" --wait --timeout 5m

harbor-configure-oidc:
  file.managed:
    - watch:
      - cmd: harbor
    - name: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/auth-oidc.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - runas: root
    - name: |
        http --auth "admin:{{ harbor.admin_password }}" PUT https://{{ harbor.core_ingress_host }}.{{ public_domain }}/api/configurations < /srv/kubernetes/manifests/harbor/auth-oidc.json