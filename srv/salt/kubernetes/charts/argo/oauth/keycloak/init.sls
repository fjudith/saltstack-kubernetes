# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import argo_cd with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/keycloak/scripts/argo:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
/get-clientsecret.sh
argo-cd-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress.host }}.{{ public_domain }}/auth/realms/{{ argo_cd.oauth.keycloak.realm }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200

argo-cd-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/realms.json
    - source: salt://{{ tpldir }}/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/argo/oauth/cd
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/kc-config-argo-cd.sh
    - source: salt://{{ tpldir }}/scripts/kc-config-argo-cd.sh
    - require:
      - http: argo-cd-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo/oauth/cd
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress.host }}.{{ public_domain }}"
      - REALM: "{{ argo_cd.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/oauth/cd/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/argo/oauth/cd
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

argo-cd-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/users-group.json
    - source: salt://{{ tpldir }}/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/argo/oauth/cd
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/kc-config-argo-cd.sh
    - source: salt://{{ tpldir }}/scripts/kc-config-argo-cd.sh
    - require:
      - http: argo-cd-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo/oauth/cd
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress.host }}.{{ public_domain }}"
      - REALM: "{{ argo_cd.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/argo/oauth/cd/admins-group.json
      - file: /srv/kubernetes/manifests/argo/oauth/cd/users-group.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/oauth/cd/groups-client-scopes.json:
  file.managed:
    - name: 
    - source: salt://{{ tpldir }}/files/groups-client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/argo/oauth/cd
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

argo-cd-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/client-scopes.json
    - source: salt://{{ tpldir }}/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/argo/oauth/cd
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/kc-config-argo-cd.sh
    - source: salt://{{ tpldir }}/scripts/kc-config-argo-cd.sh
    - require:
      - http: argo-cd-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo/oauth/cd
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress.host }}.{{ public_domain }}"
      - REALM: "{{ argo_cd.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/argo/oauth/cd/client-scopes.json
      - file: /srv/kubernetes/manifests/argo/oauth/cd/groups-client-scopes.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/oauth/cd/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/oauth/cd/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/oauth/cd/username-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/username-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/oauth/cd/userid-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/files/userid-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

argo-cd-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/client.json
    - source: salt://{{ tpldir }}/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/argo/oauth/cd
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/argo/oauth/cd/kc-config-argo-cd.sh
    - source: salt://{{ tpldir }}/scripts/kc-config-argo-cd.sh
    - require:
      - http: argo-cd-wait-keycloak
    - cwd: /srv/kubernetes/manifests/argo/oauth/cd
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress.host }}.{{ public_domain }}"
      - REALM: "{{ argo_cd.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/argo/oauth/cd/protocolmapper.json
      - file: /srv/kubernetes/manifests/argo/oauth/cd/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/argo/oauth/cd/client.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/oauth/cd/kc-clientsecret-argo-cd.sh:
  file.managed:
    - source: salt://{{ tpldir }}/scripts/kc-clientsecret-argo-cd.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}


argo-cd-server-sso-secrets:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo/oauth/cd
    - name: /srv/kubernetes/manifests/argo/oauth/cd/secrets.yaml
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
      - file: /srv/kubernetes/manifests/argo/oauth/cd/secrets.yaml
      - cmd: argo-cd-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/argo/oauth/cd/secrets.yaml