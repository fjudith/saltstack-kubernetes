{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- set keycloak_password = salt['cmd.shell']("kubectl get secret --namespace keycloak keycloak-http -o jsonpath='{.data.password}' | base64 --decode; echo") -%}

/srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/templates/rook-ceph.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644

/srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph-protocolmapper.json:
  file.managed:
    - source: salt://kubernetes/charts/keycloak-gatekeeper/files/rook-ceph-protocolmapper.json
    - user: root
    - group: root
    - mode: 644

keycloak-rook-ceph:
  cmd.run:
    - cwd: /srv/kubernetes/manifests/keycloak-gatekeeper
    - watch:
      - cmd: keycloak-create-realm
      - cmd: keycloak-create-groups
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph.json
      - file: /srv/kubernetes/manifests/keycloak-gatekeeper/rook-ceph-protocolmapper.json
    - runas: root
    - use_vt: true
    - name: |
        ./kcgk-injector.sh create-client-rook-ceph keycloak {{ keycloak_password }} https://{{ charts.keycloak.ingress_host }}.{{ public_domain }} {{ charts.keycloak_gatekeeper.realm }} https://ceph.{{ public_domain }}
