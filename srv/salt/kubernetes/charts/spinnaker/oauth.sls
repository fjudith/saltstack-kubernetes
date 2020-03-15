{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

spinnaker-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ charts.spinnaker.oauth.keycloak.realm }}/"
    - wait_for: 180
    - request_interval: 5
    - status: 200

spinnaker-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/realms.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/spinnaker/admins-group.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

spinnaker-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/users-group.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/admins-group.json
      - file: /srv/kubernetes/manifests/spinnaker/users-group.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

spinnaker-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/client-scopes.json
    - source: salt://{{ tpldir }}/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/client-scopes.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/spinnaker/protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}


/srv/kubernetes/manifests/spinnaker/groups-protocolmapper.json:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

spinnaker-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/client.json
    - source: salt://{{ tpldir }}/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - template: jinja
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/protocolmapper.json
      - file: /srv/kubernetes/manifests/spinnaker/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/spinnaker/client.json
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/spinnaker/kc-clientsecret-spinnaker.sh:
  file.managed:
    - source: salt://{{ tpldir }}/oauth/keycloak/scripts/kc-clientsecret-spinnaker.sh
    - user: root
    - group: root
    - template: jinja
    - mode: "0744"
    - context:
      tpldir: {{ tpldir }}