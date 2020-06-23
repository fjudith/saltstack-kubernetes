# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak_gatekeeper with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

/srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager.json:
  file.managed:
    - source: salt://{{ tpldir }}/templates/alertmanager.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/alertmanager-protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

keycloak-alertmanager:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager-protocolmapper.json
    - use_vt: True
    - runas: root
    - name: |
        ./kcgk-injector.sh create-client-alertmanager keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ keycloak_gatekeeper.realm }} https://{{ common.addons.kube_prometheus.alertmanager_ingress_host }}.{{ public_domain }}

/srv/kubernetes/manifests/keycloak-gatekeeper/prometheus.json:
  file.managed:
    - source: salt://{{ tpldir }}/templates/prometheus.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/keycloak-gatekeeper/prometheus-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/prometheus-protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

keycloak-prometheus:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/prometheus.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/prometheus-protocolmapper.json
    - use_vt: True
    - runas: root
    - name: |
        ./kcgk-injector.sh create-client-prometheus keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ keycloak_gatekeeper.realm }} https://{{ common.addons.kube_prometheus.prometheus_ingress_host }}.{{ public_domain }}