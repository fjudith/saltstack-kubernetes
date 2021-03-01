# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import ory with context %}
{%- from "kubernetes/map.jinja" import common with context -%}

{%- if ory.kratos.get('cockroachdb', {'enabled': False}).enabled %}
kratos-cockroachdb:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/kratos-cockroachdb-values.yaml
      - cmd: ory-namespace
      - cmd: kratos-fetch-charts
      - cmd: cockroachdb-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/cockroachdb
    - name: |
        helm upgrade --install kratos-cockroachdb --namespace ory \
          --values /srv/kubernetes/manifests/ory/kratos-cockroachdb-values.yaml \
          "./" --wait --timeout 3m
{%- endif %}

kratos-secrets:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - name: /srv/kubernetes/manifests/ory/kratos-secrets.yaml
    - source: salt://{{ tpldir }}/templates/kratos-secrets.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/kratos-secrets.yaml
      - cmd: ory-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/ory/kratos-secrets.yaml

kratos-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/kratos-ingress.yaml
    - source: salt://{{ tpldir }}/templates/kratos-ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kratos-ingress.yaml
      - cmd: ory-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/kratos-ingress.yaml

kratos:
  cmd.run:
    - runas: root
    - watch:
      {%- if ory.kratos.get('cockroachdb', {'enabled': False}).enabled %}
      - cmd: kratos-cockroachdb
      {%- endif %}
      - file: /srv/kubernetes/manifests/ory/kratos-values.yaml
      - file: /srv/kubernetes/manifests/ory/kratos-mailslurper.yaml
      - cmd: ory-namespace
      - cmd: kratos-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/kratos
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/ory/kratos-mailslurper.yaml

        helm upgrade --install kratos --namespace ory \
          --values /srv/kubernetes/manifests/ory/kratos-values.yaml \
          "./" --wait --timeout 3m