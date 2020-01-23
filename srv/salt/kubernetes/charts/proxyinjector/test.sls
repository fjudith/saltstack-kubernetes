{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

query-proxyinjector-demo:
  http.wait_for_successful_query:
    - watch:
      - cmd: proxyinjector-demo
      - cmd: proxyinjector-demo-ingress
    - name: https://{{ charts.proxyinjector.ingress_host }}.{{ public_domain }}
    - wait_for: 200
    - request_interval: 5
    - status: 200