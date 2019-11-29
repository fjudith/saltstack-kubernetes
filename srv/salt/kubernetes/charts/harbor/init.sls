{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/kubernetes/manifests/harbor:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

{% if charts.get('keycloak', {'enabled': False}).enabled %}
# {%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}
{%- set keycloak_password = {{ charts.keycloak.password }} -%}

harbor-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/{{ charts.harbor.oauth.keycloak.realm }}/"
    - wait_for: 180
    - request_interval: 5
    - status: 200

harbor-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/realms.json
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.harbor.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/harbor/admins-group.json:
  file.managed:
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - mode: 644

harbor-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/users-group.json
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.harbor.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/harbor/admins-group.json
      - file: /srv/kubernetes/manifests/harbor/users-group.json
    - user: root
    - group: root
    - mode: 644

harbor-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/client-scopes.json
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.harbor.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/harbor/client-scopes.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/harbor/protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/harbor/groups-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

harbor-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/harbor/client.json
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/harbor/kc-config-harbor.sh
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/scripts/kc-config-harbor.sh
    - require:
      - http: harbor-wait-keycloak
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.harbor.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/harbor/protocolmapper.json
      - file: /srv/kubernetes/manifests/harbor/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/harbor/client.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/harbor/kc-clientsecret-harbor.sh:
  file.managed:
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/scripts/kc-clientsecret-harbor.sh
    - user: root
    - group: root
    - template: jinja
    - mode: 744
{% endif %}

harbor-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/namespace.yaml
    - source: salt://kubernetes/charts/harbor/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/harbor/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/harbor/namespace.yaml

/srv/kubernetes/manifests/harbor/values.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - source: salt://kubernetes/charts/harbor/templates/values.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

harbor-repo:
  cmd.run:
    - runas: root
    - use_vt: true
    - name: |
        helm repo add harbor https://helm.goharbor.io

harbor-minio:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/object-store.yaml
    - source: salt://kubernetes/charts/harbor/templates/object-store.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/harbor/object-store.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/harbor/object-store.yaml

harbor-minio-ingress:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/ingress.yaml
    - source: salt://kubernetes/charts/harbor/templates/ingress.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: harbor
    - watch:
      - file: /srv/kubernetes/manifests/harbor/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/harbor/ingress.yaml

harbor:
  cmd.run:
    - watch:
        - cmd: harbor-repo
    - require:
      - cmd: harbor-namespace
    - runas: root
    - cwd: /srv/kubernetes/manifests/harbor
    - use_vt: true
    - name: |
        helm dependency update
        helm upgrade --install harbor \
          --namespace harbor \
          --values /srv/kubernetes/manifests/harbor/values.yaml \
          harbor/harbor

