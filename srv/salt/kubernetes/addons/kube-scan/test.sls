# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import kube_scan with context %}
{%- set public_domain = pillar['public-domain'] -%}

query-kube-scan:
  http.wait_for_successful_query:
    - watch:
      - cmd: kube-scan
      - cmd: kube-scan-ingress
    - name: https://{{ kube_scan.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200