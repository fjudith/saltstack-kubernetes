# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import ory with context %}
{%- from "kubernetes/map.jinja" import common with context -%}

{%- if ory.hydra.get('cockroachdb', {'enabled': False}).enabled %}
hydra-cockroachdb:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/hydra-cockroachdb-values.yaml
      - cmd: ory-namespace
      - cmd: hydra-fetch-charts
      - cmd: cockroachdb-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/cockroachdb
    - name: |
        helm upgrade --install hydra-cockroachdb --namespace ory \
          --values /srv/kubernetes/manifests/ory/hydra-cockroachdb-values.yaml \
          "./" --wait --timeout 3m
{%- endif %}

hydra-secrets:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - name: /srv/kubernetes/manifests/ory/hydra-secrets.yaml
    - source: salt://{{ tpldir }}/templates/hydra-secrets.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/hydra-secrets.yaml
      - cmd: ory-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/ory/hydra-secrets.yaml

/opt/hydra-linux-amd64-v{{ ory.hydra.version }}:
  archive.extracted:
    - source: https://github.com/ory/hydra/releases/download/v{{ ory.hydra.version }}/hydra_{{ ory.hydra.version }}_linux_64-bit.tar.gz
    - source_hash: {{ ory.hydra.source_hash }}
    - archive_format: tar
    - enforce_toplevel: False
    - if_missing: /opt/hydra-linux-amd64-v{{ ory.hydra.version }}

/usr/local/bin/hydra:
  file.symlink:
    - target: /opt/hydra-linux-amd64-v{{ ory.hydra.version }}/hydra

hydra:
  cmd.run:
    - runas: root
    - watch:
      {%- if ory.get('cockroachdb', {'enabled': False}).enabled %}
      - cmd: hydra-cockroachdb
      {%- endif %}
      - file: /srv/kubernetes/manifests/ory/hydra-values.yaml
      - cmd: ory-namespace
      - cmd: hydra-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/hydra
    - name: |
        helm upgrade --install hydra --namespace ory \
          --values /srv/kubernetes/manifests/ory/hydra-values.yaml \
          "./" --wait --timeout 3m

idp:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/ory/idp-values.yaml
      - cmd: ory-namespace
      - cmd: hydra-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory/example-idp
    - name: |
        helm upgrade --install hydra-idp --namespace ory \
          --values /srv/kubernetes/manifests/ory/idp-values.yaml \
          "./" --wait --timeout 3m