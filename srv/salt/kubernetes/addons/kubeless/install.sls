# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{%- from tpldir ~ "/map.jinja" import kubeless with context %}
{%- from "kubernetes/map.jinja" import common with context %}

kubeless-client:
  archive.extracted:
    - name: /tmp/kubeless-v{{ kubeless.version }}
    - source: https://github.com/kubeless/kubeless/releases/download/v{{ kubeless.version }}/kubeless_linux-amd64.zip
    - skip_verify: true
    {# - source_hash: {{ kubeless.source_hash }} #}
    - user: root
    - group: root
    - archive_format: zip
    - enforce_toplevel: false
  file.copy:
    - name: /usr/local/bin/kubeless
    - source: /tmp/kubeless-v{{ kubeless.version }}/bundles/kubeless_linux-amd64/kubeless
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /tmp/kubeless-v{{ kubeless.version }}
    - unless: cmp -s /usr/local/bin/kubeless /tmp/kubeless-v{{ kubeless.version }}/bundles/kubeless_linux-amd64/kubeless

kubeless:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/kubeless.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kubeless.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

kubeless-ui:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/kubeless-ui.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kubeless-ui.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

kubeless-kafa-trigger:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/kafka-trigger.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kafka-trigger.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

kubeless-kinesis-trigger:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/kinesis-trigger.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kinesis-trigger.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

{% if common.addons.get('nats_operator', {'enabled': False}).enabled %}
kubeless-nats-trigger:
  cmd.run:
    - require:
        - cmd: kubeless
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/nats-trigger.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/nats-trigger.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
{% endif %}