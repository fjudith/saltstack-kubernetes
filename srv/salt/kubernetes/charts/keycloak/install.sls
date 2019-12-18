{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

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
