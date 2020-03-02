# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import vistio with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

vistio:
  cmd.run:
    - watch:
        - git:  vistio-addon
        - file: /srv/kubernetes/manifests/vistio-values.yaml
    - runas: root
    - unless: helm list | grep vistio
    - cwd: /srv/kubernetes/manifests/vistio
    - name: |
        helm upgrade --install vistio --namespace default \
          --values /srv/kubernetes/manifests/vistio-values.yaml \
          --set web.env.updateURL=https://{{ vistio.ingress_host }}-api.{{ public_domain }}/graph \
          {%- if storage.get('rook_ceph', {'enabled': False}).enabled %}
          --set api.storage.class=rook-ceph-block \
          {%- endif %}
          "helm/vistio"

