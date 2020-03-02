# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import concourse with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

/opt/fly-linux-amd64-v{{ concourse.version }}:
  archive.extracted:
    - source: https://github.com/concourse/concourse/releases/download/v{{ concourse.version }}/fly-{{ concourse.version }}-linux-amd64.tgz
    - source_hash: {{ concourse.source_hash }}
    - archive_format: tar
    - enforce_toplevel: false
    - if_missing: /opt/fly-linux-amd64-v{{ concourse.version }}

/usr/local/bin/fly:
  file.symlink:
    - target: /opt/fly-linux-amd64-v{{ concourse.version }}/fly


concourse:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/concourse/values.yaml
      - file: /srv/kubernetes/manifests/concourse/concourse/requirements.yaml
      - cmd: concourse-namespace
      - cmd: concourse-fetch-charts
    - cwd: /srv/kubernetes/manifests/concourse/concourse
    - name: |
        helm upgrade --install concourse --namespace concourse \
            --set concourse.web.externalUrl=https://{{ concourse.ingress_host }}.{{ public_domain }} \
            --set concourse.worker.driver=detect \
            --set imageTag="{{ concourse.version }}" \
            --set postgresql.enabled=true \
            --set postgresql.password={{ concourse.db_password }} \
            {%- if storage.get('rook_ceph', {'enabled': False}).enabled %}
            --values /srv/kubernetes/manifests/concourse/values.yaml \
            {%- endif %}
            "./" --wait --timeout 5m