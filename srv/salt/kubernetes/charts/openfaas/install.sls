# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openfaas with context %}

/opt/faas-cli-v{{ openfaas.client_version }}:
  file.managed:
    - source: https://github.com/openfaas/faas-cli/releases/download/{{ openfaas.client_version }}/faas-cli
    - source_hash: {{ openfaas.client_source_hash }}
    - mode: "0755"
    - user: root
    - group: root
    - if_missing: /opt/faas-cli-v{{ openfaas.client_version }}

/usr/local/bin/faas-cli:
  file.symlink:
    - target: /opt/faas-cli-v{{ openfaas.client_version }}


openfaas-secrets:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/secrets.yaml
      - cmd: openfaas-namespace
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openfaas/secrets.yaml

openfaas:
  cmd.run:
    - runas: root
    - require:
      - cmd: openfaas-secrets
      - cmd: openfaas-namespace
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/values.yaml
      - cmd: openfaas-fetch-charts
    - cwd: /srv/kubernetes/manifests/openfaas/openfaas
    - name: |
        helm upgrade --install openfaas --namespace openfaas \
          --values /srv/kubernetes/manifests/openfaas/values.yaml \
          "./" --wait --timeout 5m

openfaas-cron-connector:
  cmd.run:
    - runas: root
    - require:
      - cmd: openfaas-cron-connector-fetch-charts
      - cmd: openfaas
    - cwd: /srv/kubernetes/manifests/openfaas/cron-connector
    - name: |
        helm upgrade --install cron-connector --namespace openfaas \
          "./" --wait --timeout 5m

openfaas-nats-connector:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/nats-connector-deployment.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openfaas/nats-connector-deployment.yaml