# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import vistio with context %}
{%- from "kubernetes/map.jinja" import common with context -%}

vistio-addon:
  git.latest:
    - name: https://github.com/fjudith/vistio
    - target: /srv/kubernetes/manifests/vistio
    - force_reset: True
    - rev: v{{ vistio.version }}

{% if common.addons.get('nginx', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/vistio-values.yaml:
    file.managed:
    - source: salt://{{ tpldir }}/files/values-mesh-only.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{%- else -%}
/srv/kubernetes/manifests/vistio-values.yaml:
    file.managed:
    - source: salt://{{ tpldir }}/files/values-with-ingress.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
{% endif %}