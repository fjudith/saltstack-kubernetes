# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

keycloak-secrets:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - name: /srv/kubernetes/manifests/keycloak/secrets.yaml
    - source: salt://{{ tpldir }}/templates/secrets.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/secrets.yaml
      - cmd: keycloak-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/keycloak/secrets.yaml

keycloak:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/values.yaml
      - cmd: keycloak-namespace
      - cmd: keycloak-fetch-charts
      - cmd: keycloak-secrets
    - onlyif: kubectl get storageclass | grep \(default\)
    - cwd: /srv/kubernetes/manifests/keycloak/keycloak
    - name: |
        helm repo update && \
        helm upgrade --install keycloak --namespace keycloak \
            --set keycloak.image.tag={{ keycloak.version }} \
            {%- if storage.get('rook_ceph', {'enabled': False}).enabled or storage.get('rook_edgefs', {'enabled': False}).enabled or storage.get('portworx', {'enabled': False}).enabled %}
            -f /srv/kubernetes/manifests/keycloak/values.yaml \
            {%- endif %}
            "./" --wait --timeout 5m
