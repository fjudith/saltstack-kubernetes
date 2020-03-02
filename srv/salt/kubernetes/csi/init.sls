{%- from "kubernetes/map.jinja" import storage with context -%}

include:
{%- if storage.get('rook_ceph', {'enabled': False}).enabled %}
  - kubernetes.csi.rook-ceph
{%- endif -%}
{%- if storage.get('minio_operator', {'enabled': False}).enabled %}
  - kubernetes.csi.minio-operator
{%- endif -%}