{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

demo-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ charts.proxyinjector.oauth.keycloak.realm }}/"
    - wait_for: 180
    - request_interval: 5
    - status: 200

demo-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/proxyinjector/realms.json
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/proxyinjector/kc-config-demo.sh
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/scripts/kc-config-demo.sh
    - require:
      - http: demo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/proxyinjector
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.proxyinjector.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/proxyinjector/admins-group.json:
  file.managed:
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - group: root
    - mode: 644

demo-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/proxyinjector/users-group.json
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/proxyinjector/kc-config-demo.sh
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/scripts/kc-config-demo.sh
    - require:
      - http: demo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/proxyinjector
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.proxyinjector.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/proxyinjector/admins-group.json
      - file: /srv/kubernetes/manifests/proxyinjector/users-group.json
    - user: root
    - group: root
    - mode: 644

demo-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/proxyinjector/client-scopes.json
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/proxyinjector/kc-config-demo.sh
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/scripts/kc-config-demo.sh
    - require:
      - http: demo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/proxyinjector
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.proxyinjector.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/proxyinjector/client-scopes.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/proxyinjector/protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/proxyinjector/groups-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

demo-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/proxyinjector/client.json
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/proxyinjector/kc-config-demo.sh
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/scripts/kc-config-demo.sh
    - require:
      - http: demo-wait-keycloak
    - cwd: /srv/kubernetes/manifests/proxyinjector
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ charts.keycloak.password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.proxyinjector.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/proxyinjector/protocolmapper.json
      - file: /srv/kubernetes/manifests/proxyinjector/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/proxyinjector/client.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/proxyinjector/kc-clientsecret-demo.sh:
  file.managed:
    - source: salt://kubernetes/charts/proxyinjector/oauth/keycloak/scripts/kc-clientsecret-demo.sh
    - user: root
    - group: root
    - template: jinja
    - mode: 744