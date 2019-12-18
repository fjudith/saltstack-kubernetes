{%- from "kubernetes/map.jinja" import charts with context -%}

helm-charts:
  git.latest:
    - name: https://github.com/fjudith/charts
    - target: /srv/kubernetes/charts
    - force_reset: True
    - rev: {{ charts.keycloak_gatekeeper.version }}
