# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openfaas with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

openfaas-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ openfaas.oauth.keycloak.realm }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200

openfaas-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/openfaas/realms.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/openfaas/kc-config-openfaas.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-openfaas.sh
    - require:
      - http: openfaas-wait-keycloak
    - cwd: /srv/kubernetes/manifests/openfaas
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ openfaas.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"

/srv/kubernetes/manifests/openfaas/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - user: root
    - group: root
    - mode: "0644"

openfaas-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/openfaas/users-group.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/openfaas/kc-config-openfaas.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-openfaas.sh
    - require:
      - http: openfaas-wait-keycloak
    - cwd: /srv/kubernetes/manifests/openfaas
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ openfaas.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/admins-group.json
      - file: /srv/kubernetes/manifests/openfaas/users-group.json
    - user: root
    - group: root
    - mode: "0644"

openfaas-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/openfaas/client-scopes.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/openfaas/kc-config-openfaas.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-openfaas.sh
    - require:
      - http: openfaas-wait-keycloak
    - cwd: /srv/kubernetes/manifests/openfaas
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ openfaas.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/client-scopes.json
    - user: root
    - group: root
    - mode: "0644"

/srv/kubernetes/manifests/openfaas/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/openfaas/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/openfaas/username-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/username-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"

/srv/kubernetes/manifests/openfaas/userid-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/userid-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

openfaas-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/openfaas/client.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/openfaas/kc-config-openfaas.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-openfaas.sh
    - require:
      - http: openfaas-wait-keycloak
    - cwd: /srv/kubernetes/manifests/openfaas
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ openfaas.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/protocolmapper.json
      - file: /srv/kubernetes/manifests/openfaas/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/openfaas/client.json
    - user: root
    - group: root
    - mode: "0644"

/srv/kubernetes/manifests/openfaas/kc-clientsecret-openfaas.sh:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-clientsecret-openfaas.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}
