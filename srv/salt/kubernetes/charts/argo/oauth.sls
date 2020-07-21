# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import argo with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

argo-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ argo.oauth.keycloak.realm }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200

argo-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/realms.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/argo
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/kc-config-argo.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-argo.sh
    - require:
      - http: argo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ argo.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/argo
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

argo-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/users-group.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/argo
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/kc-config-argo.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-argo.sh
    - require:
      - http: argo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ argo.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/argo/admins-group.json
      - file: /srv/kubernetes/manifests/argo/users-group.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

argo-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/client-scopes.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/argo
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/kc-config-argo.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-argo.sh
    - require:
      - http: argo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ argo.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/argo/client-scopes.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/username-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/username-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/userid-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/userid-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

argo-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/client.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/argo
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/kc-config-argo.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-argo.sh
    - require:
      - http: argo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ argo.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/argo/protocolmapper.json
      - file: /srv/kubernetes/manifests/argo/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/argo/client.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/kc-clientsecret-argo.sh:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-clientsecret-argo.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}


argo-server-sso-secrets:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/secrets.yaml
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
      - file: /srv/kubernetes/manifests/argo/secrets.yaml
      - cmd: argo-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/argo/secrets.yaml