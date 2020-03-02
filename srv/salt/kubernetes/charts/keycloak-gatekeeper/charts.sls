# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import keycloak_gatekeeper with context %}

helm-charts:
  git.latest:
    - name: https://github.com/fjudith/charts
    - target: /srv/kubernetes/charts
    - force_reset: True
    - rev: {{ keycloak_gatekeeper.version }}
