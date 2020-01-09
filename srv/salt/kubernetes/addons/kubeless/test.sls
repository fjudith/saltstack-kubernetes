{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}

query-kubeless-ui:
  http.wait_for_successful_query:
    - watch:
      - cmd: kubeless
      - cmd: kubeless-ingress
    - name: https://{{ common.addons.kubeless.ingress_host }}.{{ public_domain }}/
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 200