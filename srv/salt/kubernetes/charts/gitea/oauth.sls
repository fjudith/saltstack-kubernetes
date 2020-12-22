# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import gitea with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

gitea-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ gitea.oauth.keycloak.realm }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200

gitea-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/gitea/realms.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/gitea
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/gitea/kc-config-gitea.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-gitea.sh
    - require:
      - http: gitea-wait-keycloak
    - cwd: /srv/kubernetes/manifests/gitea
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ gitea.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/gitea/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/gitea
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

gitea-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/gitea/users-group.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/gitea
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/gitea/kc-config-gitea.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-gitea.sh
    - require:
      - http: gitea-wait-keycloak
    - cwd: /srv/kubernetes/manifests/gitea
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ gitea.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/gitea/admins-group.json
      - file: /srv/kubernetes/manifests/gitea/users-group.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

gitea-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/gitea/client-scopes.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/gitea
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/gitea/kc-config-gitea.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-gitea.sh
    - require:
      - http: gitea-wait-keycloak
    - cwd: /srv/kubernetes/manifests/gitea
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ gitea.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/gitea/client-scopes.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/gitea/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/gitea/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/gitea/username-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/username-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/gitea/userid-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/userid-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

gitea-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/gitea/client.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/gitea
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/gitea/kc-config-gitea.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-gitea.sh
    - require:
      - http: gitea-wait-keycloak
    - cwd: /srv/kubernetes/manifests/gitea
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ gitea.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/gitea/protocolmapper.json
      - file: /srv/kubernetes/manifests/gitea/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/gitea/client.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/gitea/kc-clientsecret-gitea.sh:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-clientsecret-gitea.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}