{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

harbor:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - watch:
        - cmd: harbor-namespace
        - cmd: harbor-fetch-charts
        - file: /srv/kubernetes/manifests/harbor/values.yaml
    - cwd: /srv/kubernetes/manifests/harbor/harbor
    - use_vt: true
    - name: |
        helm dependency update
        helm upgrade --install harbor \
          --namespace harbor \
          --values /srv/kubernetes/manifests/harbor/values.yaml \
          "./" --wait --timeout 5m

harbor-configure-oidc:
  file.managed:
    - watch:
      - cmd: harbor
    - name: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - source: salt://kubernetes/charts/harbor/oauth/keycloak/templates/auth-oidc.json.j2
    - user: root
    - group: root
    - template: jinja
    - mode: 644
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/harbor/auth-oidc.json
    - runas: root
    - name: |
        http --auth "admin:{{ charts.harbor.admin_password }}" PUT https://{{ charts.harbor.core_ingress_host }}.{{ public_domain }}/api/configurations < /srv/kubernetes/manifests/harbor/auth-oidc.json