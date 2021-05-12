# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import harbor with context %}

harbor-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/harbor/harbor

harbor-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: harbor-remove-charts
      - file: /srv/kubernetes/manifests/harbor
    - cwd: /srv/kubernetes/manifests/harbor
    - name: |
        helm repo add harbor https://helm.goharbor.io
        helm repo update
        helm fetch --untar harbor/harbor --version v{{ harbor.version }}


/srv/kubernetes/manifests/harbor/harbor/templates/nginx/deployment.yaml:
  file.managed:
    - source: salt://{{tpldir }}/patch/nginx-deployment.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
