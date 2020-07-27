# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import ory with context %}

oathkeeper-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/oathkeeper-ingress.yaml
    - source: salt://{{ tpldir }}/templates/oathkeeper-ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/oathkeeper-ingress.yaml
      - cmd: ory-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/oathkeeper-ingress.yaml

oathkeeper:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/oathkeeper-values.yaml
      - cmd: ory-namespace
      - cmd: oathkeeper-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/oathkeeper
    - name: |
        helm upgrade --install oathkeeper --namespace ory \
          --values /srv/kubernetes/manifests/ory/oathkeeper-values.yaml \
          "./" --wait --timeout 3m
