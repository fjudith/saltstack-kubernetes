{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

concourse-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ charts.concourse.oauth.keycloak.realm }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200

concourse-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/realms.json
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.concourse.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/concourse/admins-group.json:
  file.managed:
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - mode: 644

concourse-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/users-group.json
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.concourse.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/concourse/admins-group.json
      - file: /srv/kubernetes/manifests/concourse/users-group.json
    - user: root
    - group: root
    - mode: 644

concourse-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/client-scopes.json
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.concourse.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/concourse/client-scopes.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/concourse/protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/concourse/groups-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/concourse/username-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/files/username-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/concourse/userid-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/files/userid-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

concourse-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse/client.json
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/concourse/kc-config-concourse.sh
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/scripts/kc-config-concourse.sh
    - require:
      - http: concourse-wait-keycloak
    - cwd: /srv/kubernetes/manifests/concourse
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.concourse.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/concourse/protocolmapper.json
      - file: /srv/kubernetes/manifests/concourse/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/concourse/client.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/concourse/kc-clientsecret-concourse.sh:
  file.managed:
    - source: salt://kubernetes/charts/concourse/oauth/keycloak/scripts/kc-clientsecret-concourse.sh
    - user: root
    - group: root
    - template: jinja
    - mode: 744
