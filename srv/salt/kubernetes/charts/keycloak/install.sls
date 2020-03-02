# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

keycloak:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/values.yaml
      - file: /srv/kubernetes/manifests/keycloak/keycloak/requirements.yaml
      - cmd: keycloak-namespace
      - cmd: keycloak-fetch-charts
    - only_if: kubectl get storageclass | grep \(default\)
    - cwd: /srv/kubernetes/manifests/keycloak/keycloak
    - name: |
        helm repo update && \
        helm upgrade --install keycloak --namespace keycloak \
            --set keycloak.image.tag={{ keycloak.version }} \
            --set keycloak.password={{ keycloak.password }} \
            {%- if storage.get('rook_ceph', {'enabled': False}).enabled %}
            -f /srv/kubernetes/manifests/keycloak/values.yaml \
            {%- endif %}
            "./" --wait --timeout 5m
