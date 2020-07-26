# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import velero with context %}
{% from "kubernetes/map.jinja" import storage with context %}
{% from "kubernetes/map.jinja" import common with context %}

include:
  - .config
  - .charts
  - .namespace
  - .ingress
  {%- if storage.get('minio_operator', {'enabled': False}).enabled and velero.get('s3', {'enabled': False}).enabled %}
  - .minio
  {%- endif %}
  {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
  - .prometheus
  {%- endif %}
  - .install
  - .test