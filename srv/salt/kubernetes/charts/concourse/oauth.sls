# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import concourse with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

concourse-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ concourse.oauth.keycloak.realm }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200

concourse-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/realms.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ concourse.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/concourse/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

concourse-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/users-group.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ concourse.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/concourse/admins-group.json
      - file: /srv/kubernetes/manifests/concourse/users-group.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

concourse-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/client-scopes.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ concourse.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/concourse/client-scopes.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/concourse/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/concourse/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/concourse/username-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/username-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/concourse/userid-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/userid-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

concourse-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/client.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ concourse.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/concourse/protocolmapper.json
      - file: /srv/kubernetes/manifests/concourse/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/concourse/client.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/concourse/kc-clientsecret-concourse.sh:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-clientsecret-concourse.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}
