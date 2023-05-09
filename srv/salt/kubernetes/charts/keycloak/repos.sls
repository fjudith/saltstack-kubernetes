# -*- coding: utf-8 -*-
# vim: ft=jinja

{%- from tpldir ~ "/map.jinja" import keycloak with context %}

bitnami-repos:
  helm.repo_managed:
    {%- if keycloak.enabled %}
    - present:
      - name: bitnami
        url: {{ keycloak.url }}
    {%- else%}
    - absent:
      - bitnami
    {%- endif %}
