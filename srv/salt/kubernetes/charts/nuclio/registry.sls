# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import nuclio with context %}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- set public_domain = pillar['public-domain'] -%}

{% if nuclio.registry.get('dockerhub', {'enabled': False}).enabled %}
nuclio-dockerhub:
  file.managed:
    - name: /srv/kubernetes/manifests/nuclio/dockerhub-secret.yaml
    - source: salt://{{ tpldir }}/templates/dockerhub-secret.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/nuclio/dockerhub-secret.yaml
      - cmd: nuclio-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/nuclio/dockerhub-secret.yaml
{% endif %}

{% if nuclio.registry.get('quay', {'enabled': False}).enabled %}
nuclio-quay:
  file.managed:
    - name: /srv/kubernetes/manifests/nuclio/quay-secret.yaml
    - source: salt://{{ tpldir }}/templates/quay-secret.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/nuclio/quay-secret.yaml
      - cmd: nuclio-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/nuclio/quay-secret.yaml
{% endif %}

{% if nuclio.registry.get('harbor', {'enabled': False}).enabled %}
nuclio-harbor:
  file.managed:
    - name: /srv/kubernetes/manifests/nuclio/harbor-secret.yaml
    - source: salt://{{ tpldir }}/templates/harbor-secret.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/nuclio/harbor-secret.yaml
      - cmd: nuclio-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/nuclio/harbor-secret.yaml
{% endif %}

{% if charts.get('harbor', {'enabled': False}).enabled %}
nuclio-local-harbor:
  cmd.run:
    - watch:
      - cmd: nuclio-namespace
    - runas: root
    - name: |
        kubectl -n nuclio get secret registry-harbor-local || \
        kubectl -n nuclio create secret docker-registry registry-harbor-local \
          --docker-username admin \
          --docker-password {{ charts.harbor.adminPassword }} \
          --docker-server {{ charts.harbor.coreIngressHost }}.{{ public_domain }} \
          --docker-email ignored@nuclio.io
{% endif %}