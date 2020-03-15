# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import harbor with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}


harbor-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ harbor.oauth.keycloak.realm }}/"
    - wait_for: 180
    - request_interval: 5
    - status: 200

harbor-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/realms.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ harbor.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/harbor/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

harbor-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/users-group.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ harbor.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/harbor/admins-group.json
      - file: /srv/kubernetes/manifests/harbor/users-group.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

harbor-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/client-scopes.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ harbor.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/harbor/client-scopes.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/harbor/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/harbor/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

harbor-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/client.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ harbor.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/harbor/protocolmapper.json
      - file: /srv/kubernetes/manifests/harbor/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/harbor/client.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/harbor/kc-clientsecret-harbor.sh:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-clientsecret-harbor.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}