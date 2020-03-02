# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak_gatekeeper with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

/srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope.json:
  file.managed:
    - source: salt://{{ tpldir }}/templates/weave-scope.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/weave-scope-protocolmapper.json
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

keycloak-weave-scope:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/weave-scope-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-weave-scope keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ keycloak_gatekeeper.realm }} https://{{ common.addons.weave_scope.ingress_host }}.{{ public_domain }}
