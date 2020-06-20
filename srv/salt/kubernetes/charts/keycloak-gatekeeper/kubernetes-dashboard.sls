# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak_gatekeeper with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

/srv/kubernetes/manifests/keycloak-gatekeeper/files:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json:
  file.managed:
    - source: salt://{{ tpldir }}/templates/kubernetes-dashboard.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/kubernetes-dashboard-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/keycloak-gatekeeper/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/keycloak-gatekeeper/files/keycloak-kubernetes-rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/files
    - source: salt://{{ tpldir }}/templates/keycloak-kubernetes-rbac.yaml.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

keycloak-kubernetes-dashboard:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard-protocolmapper.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/files/keycloak-kubernetes-rbac.yaml
    - runas: root
    - name: |
        ./kcgk-injector.sh create-client-kubernetes keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ keycloak_gatekeeper.realm }} https://{{ common.addons.dashboard.ingress_host }}.{{ public_domain }}
