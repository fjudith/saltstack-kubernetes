{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/srv/kubernetes/manifests/keycloak:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/keycloak/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - source: salt://kubernetes/charts/keycloak/files/values.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - source: salt://kubernetes/charts/keycloak/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

keycloak:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/values.yaml
    - runas: root
    # - unless: helm list | grep keycloak
    - only_if: kubectl get storageclass | grep \(default\)
    - name: |
        helm repo add codecentric https://codecentric.github.io/helm-charts && \
        helm repo update && \
        helm upgrade --install keycloak --namespace keycloak \
            --set keycloak.image.tag={{ charts.keycloak.version }} \
            {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
            -f /srv/kubernetes/manifests/keycloak/values.yaml \
            {%- endif %}
            "codecentric/keycloak"

keycloak-ingress:
    cmd.run:
      - require:
        - cmd: keycloak
      - watch:
        - file: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml