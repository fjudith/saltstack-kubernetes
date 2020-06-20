# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import weave_scope with context %}
{%- set public_domain = pillar['public-domain'] -%}

weave-scope-wait:
  cmd.run:
    - require:
      - cmd: weave-scope
    - runas: root
    - name: |
        until kubectl -n weave get pods --field-selector=status.phase=Running --selector=app=weave-scope; do printf 'weave-scope is not Running' && sleep 5; done
    - timeout: 180

query-weave-scope:
  http.wait_for_successful_query:
    - watch:
      - cmd: weave-scope
      - cmd: weave-scope-ingress
    - name: https://{{ weave_scope.ingress_host }}.{{ public_domain }}
    - wait_for: 120
    - request_interval: 5
    - status: 200