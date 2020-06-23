# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak_gatekeeper with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

keycloak-create-realm:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/realms.json
    - use_vt: True
    - runas: root
    - name: |
        ./kcgk-injector.sh create-realm keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ keycloak_gatekeeper.realm }}

keycloak-create-groups:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - cmd: keycloak-create-realm
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/keycloak-kubernetes-admins-group.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/keycloak-kubernetes-users-group.json
    - use_vt: True
    - runas: root
    - name: |
        ./kcgk-injector.sh create-groups keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ keycloak_gatekeeper.realm }}

keycloak-create-client-scopes:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch: 
      - cmd: keycloak-create-realm
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/client-scopes.json  
    - use_vt: True
    - runas: root
    - name: |
        ./kcgk-injector.sh create-client-scopes keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ keycloak_gatekeeper.realm }}
