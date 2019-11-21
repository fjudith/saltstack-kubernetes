{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/kubernetes/manifests/spinnaker:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/spinnaker/namespace.yaml:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: 644

{% if charts.get('keycloak', {'enabled': False}).enabled %}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

spinnaker-wait-keycloak:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
    - wait_for: 180
    - request_interval: 5
    - status: 200


spinnaker-create-realm:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/realms.json
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/templates/realms.json.j2
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-realm"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/spinnaker/admins-group.json:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/files/admins-group.json
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: 644

spinnaker-create-groups:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/users-group.json
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/files/users-group.json
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-groups"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/admins-group.json
      - file: /srv/kubernetes/manifests/spinnaker/users-group.json
    - user: root
    - group: root
    - mode: 644

spinnaker-create-client-scopes:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/client-scopes.json
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/files/client-scopes.json
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-client-scopes"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/client-scopes.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/spinnaker/protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/files/protocolmapper.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/spinnaker/groups-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

spinnaker-create-client:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/client.json
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/templates/client.json.j2
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.script:
    - name: /srv/kubernetes/manifests/spinnaker/kc-config-spinnaker.sh
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/scripts/kc-config-spinnaker.sh
    - require:
      - http: spinnaker-wait-keycloak
    - cwd: /srv/kubernetes/manifests/spinnaker
    - env:
      - ACTION: "create-client"
      - USERNAME: "keycloak"
      - PASSWORD: "{{ keycloak_password }}"
      - URL: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}"
      - REALM: "{{ charts.spinnaker.oauth.keycloak.realm }}"
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/protocolmapper.json
      - file: /srv/kubernetes/manifests/spinnaker/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/spinnaker/client.json
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/spinnaker/kc-clientsecret-spinnaker.sh:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/oauth/keycloak/scripts/kc-clientsecret-spinnaker.sh
    - user: root
    - group: root
    - template: jinja
    - mode: 744
{% endif %}

/srv/kubernetes/manifests/spinnaker/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/spinnaker
    - source: salt://kubernetes/charts/spinnaker/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja

spinnaker-namespace:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/spinnaker/namespace.yaml

{% if master.storage.get('rook_minio', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/spinnaker/object-store.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - source: salt://kubernetes/charts/spinnaker/templates/object-store.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

spinnaker-minio:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/object-store.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/spinnaker/object-store.yaml
{% endif %}

spinnaker-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/ingress.yaml
    - source: salt://kubernetes/charts/spinnaker/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: spinnaker
    - watch:
      - file:  /srv/kubernetes/manifests/spinnaker/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/spinnaker/ingress.yaml

spinnaker:
  cmd.run:
    - runas: root
    - only_if: kubectl get storageclass | grep \(default\)
    - require:
      - cmd: spinnaker-namespace
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/values.yaml
    - name: |
        helm repo update && \
        helm upgrade --install --force spinnaker --namespace spinnaker \
          --set halyard.spinnakerVersion={{ charts.spinnaker.version }} \
          --set halyard.image.tag={{ charts.spinnaker.halyard_version }} \
          {%- if master.storage.get('rook_minio', {'enabled': False}).enabled %}
          --values /srv/kubernetes/manifests/spinnaker/values.yaml \
          {%- else -%}
          --set minio.enabled=true \
          --set minio.persistence.enabled=true \
          {%- endif %}
          --set redis.enabled=true \
          --set redis.cluster.enabled=true \
          --set redis.master.persistence.enabled=true \
          "stable/spinnaker"

spinnaker-front50-wait:
  cmd.run:
    - require:
      - cmd: spinnaker
    - runas: root
    - name: | 
        until kubectl -n spinnaker get pods --selector=cluster=spin-front50 --field-selector=status.phase=Running 
        do 
          printf 'spin-front50 is not Running' && sleep 5
        done
    - use_vt: True
    - timeout: 600