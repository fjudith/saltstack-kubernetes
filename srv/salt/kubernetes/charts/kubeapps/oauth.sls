# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import kubeapps with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

kubeapps-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ kubeapps.oauth.keycloak.realm }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200

kubeapps-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/kubeapps/realms.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/kubeapps
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/kubeapps/kc-config-kubeapps.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-kubeapps.sh
    - require:
      - http: kubeapps-wait-keycloak
    - cwd: /srv/kubernetes/manifests/kubeapps
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ kubeapps.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeapps/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/kubeapps
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

kubeapps-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/kubeapps/users-group.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/kubeapps
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/kubeapps/kc-config-kubeapps.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-kubeapps.sh
    - require:
      - http: kubeapps-wait-keycloak
    - cwd: /srv/kubernetes/manifests/kubeapps
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ kubeapps.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/kubeapps/admins-group.json
      - file: /srv/kubernetes/manifests/kubeapps/users-group.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

kubeapps-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/kubeapps/client-scopes.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/kubeapps
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/kubeapps/kc-config-kubeapps.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-kubeapps.sh
    - require:
      - http: kubeapps-wait-keycloak
    - cwd: /srv/kubernetes/manifests/kubeapps
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ kubeapps.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/kubeapps/client-scopes.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeapps/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeapps/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeapps/username-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/username-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeapps/userid-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/userid-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

kubeapps-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/kubeapps/client.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/kubeapps
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/kubeapps/kc-config-kubeapps.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-kubeapps.sh
    - require:
      - http: kubeapps-wait-keycloak
    - cwd: /srv/kubernetes/manifests/kubeapps
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ kubeapps.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/kubeapps/protocolmapper.json
      - file: /srv/kubernetes/manifests/kubeapps/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/kubeapps/client.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubeapps/kc-clientsecret-kubeapps.sh:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-clientsecret-kubeapps.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}
