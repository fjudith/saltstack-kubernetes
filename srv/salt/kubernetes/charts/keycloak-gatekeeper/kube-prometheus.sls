{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

/srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/alertmanager.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/alertmanager-protocolmapper.json
    - user: root
    - group: root
    - mode: 644

keycloak-alertmanager:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/alertmanager-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-alertmanager keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://alertmanager.{{ public_domain }}

/srv/kubernetes/manifests/keycloak-gatekeeper/prometheus.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/prometheus.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/prometheus-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/prometheus-protocolmapper.json
    - user: root
    - group: root
    - mode: 644

keycloak-prometheus:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/prometheus.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/prometheus-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-prometheus keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://prometheus.{{ public_domain }}