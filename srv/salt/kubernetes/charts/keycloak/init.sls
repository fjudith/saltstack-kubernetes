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

keycloak-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/keycloak
    - name: /srv/kubernetes/manifests/keycloak/namespace.yaml
    - source: salt://kubernetes/charts/keycloak/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/keycloak/namespace.yaml

keycloak:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/values.yaml
      - cmd: keycloak-namespace
    - runas: root
    # - unless: helm list | grep keycloak
    - only_if: kubectl get storageclass | grep \(default\)
    - name: |
        helm repo add codecentric https://codecentric.github.io/helm-charts && \
        helm repo update && \
        helm upgrade --install keycloak --namespace keycloak \
            --set keycloak.image.tag={{ charts.keycloak.version }} \
            --set keycloak.password={{ charts.keycloak.password }} \
            {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
            -f /srv/kubernetes/manifests/keycloak/values.yaml \
            {%- endif %}
            "codecentric/keycloak"

keycloak-ingress:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/keycloak
    - name: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
    - source: salt://kubernetes/charts/keycloak/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: keycloak
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/keycloak/keycloak-ingress.yaml

keycloak-wait-public-url:
  http.wait_for_successful_query:
    - name: "https://{{ charts.keycloak.ingressHost }}.{{ public_domain }}/auth/realms/master/"
    - wait_for: 180
    - request_interval: 5
    - status: 200