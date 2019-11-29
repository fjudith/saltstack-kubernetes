{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/concourse:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

concourse-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - name: /srv/kubernetes/manifests/concourse/namespace.yaml
    - source: salt://kubernetes/charts/concourse/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/concourse/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/concourse/namespace.yaml

{% if charts.get('keycloak', {'enabled': False}).enabled %}
# {%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}
{%- set keycloak_password = {{ charts.keycloak.password }} -%}

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
      - PASSWORD: "{{ keycloak_password }}"
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
      - PASSWORD: "{{ keycloak_password }}"
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
      - PASSWORD: "{{ keycloak_password }}"
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
      - PASSWORD: "{{ keycloak_password }}"
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
{% endif %}

/opt/fly-linux-amd64-v{{ charts.concourse.version }}:
  archive.extracted:
    - source: https://github.com/concourse/concourse/releases/download/v{{ charts.concourse.version }}/fly-{{ charts.concourse.version }}-linux-amd64.tgz
    - source_hash: {{ charts.concourse.source_hash }}
    - archive_format: tar
    - enforce_toplevel: false
    - if_missing: /opt/fly-linux-amd64-v{{ charts.concourse.version }}

/usr/local/bin/fly:
  file.symlink:
    - target: /opt/fly-linux-amd64-v{{ charts.concourse.version }}/fly

/srv/kubernetes/manifests/concourse/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/concourse
    - source: salt://kubernetes/charts/concourse/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja

/srv/kubernetes/manifests/concourse/secrets:
  file.directory:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

concourse:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/concourse
      - cmd: concourse-namespace
    - runas: root
    - name: |
        helm upgrade --install concourse --namespace concourse \
            --set concourse.web.externalUrl=https://{{ charts.concourse.ingress_host }}.{{ public_domain }} \
            --set concourse.worker.driver=detect \
            --set imageTag="{{ charts.concourse.version }}" \
            --set postgresql.enabled=true \
            --set postgresql.password={{ charts.concourse.db_password }} \
            {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
            --values /srv/kubernetes/manifests/concourse/values.yaml \
            {%- endif %}
            "stable/concourse"
            
concourse-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse-ingress.yaml
    - source: salt://kubernetes/charts/concourse/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/concourse-ingress.yaml
      - cmd: concourse-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/concourse-ingress.yaml
    