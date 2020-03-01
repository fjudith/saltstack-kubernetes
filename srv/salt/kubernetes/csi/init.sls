{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}

include:
{%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
  - kubernetes.csi.rook-ceph
{%- endif -%}
{%- if common.addons.get('minio_operator', {'enabled': False}).enabled %}
  - kubernetes.csi.minio-operator
{%- endif -%}