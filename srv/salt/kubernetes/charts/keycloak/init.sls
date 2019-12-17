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

keycloak-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/keycloak
    - cwd: /srv/kubernetes/manifests/keycloak
    - name: |
        helm repo add codecentric https://codecentric.github.io/helm-charts
        helm fetch --untar codecentric/keycloak
  file.absent:
    - name: /srv/kubernetes/manifests/keycloak/keycloak/requirements.lock

/srv/kubernetes/manifests/keycloak/keycloak/requirements.yaml:
  file.managed:
    - watch:
      - cmd: keycloak-fetch-charts
    - source: salt://kubernetes/charts/keycloak/files/requirements.yaml
    - user: root
    - group: root
    - mode: 644

keycloak:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/keycloak/values.yaml
      - file: /srv/kubernetes/manifests/keycloak/keycloak/requirements.yaml
      - cmd: keycloak-namespace
      - cmd: keycloak-fetch-charts
    - only_if: kubectl get storageclass | grep \(default\)
    - cwd: /srv/kubernetes/manifests/keycloak/keycloak
    - name: |
        helm repo update && \
        helm upgrade --install keycloak --namespace keycloak \
            --set keycloak.image.tag={{ charts.keycloak.version }} \
            --set keycloak.password={{ charts.keycloak.password }} \
            {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
            -f /srv/kubernetes/manifests/keycloak/values.yaml \
            {%- endif %}
            "./" --wait --timeout 5m

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
    - name: "https://{{ charts.keycloak.ingress_host }}.{{ public_domain }}/auth/realms/master/"
    - wait_for: 180
    - request_interval: 5
    - status: 200
    - require_in:
      - sls: kubernetes.charts.keycloak-gatekeeper
      {%- if master.storage.get('keycloak', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.keycloak
      {%- endif %}
      {%- if master.storage.get('harbor', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.harbor
      {%- endif %}
      {%- if master.storage.get('keycloak', {'enabled': False}).enabled %}
      - sls: kubernetes.charts.spinnaker
      {%- endif %}
