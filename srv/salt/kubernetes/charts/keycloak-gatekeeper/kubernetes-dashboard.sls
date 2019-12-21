{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

/srv/kubernetes/manifests/keycloak-gatekeeper/files:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/kubernetes-dashboard.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/kubernetes-dashboard-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/groups-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/groups-protocolmapper.json
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/files/keycloak-kubernetes-rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/files
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/keycloak-kubernetes-rbac.yaml.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

keycloak-kubernetes-dashboard:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/kubernetes-dashboard-protocolmapper.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/groups-protocolmapper.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/files/keycloak-kubernetes-rbac.yaml
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-kubernetes keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://kubernetes-dashboard.{{ public_domain }}
