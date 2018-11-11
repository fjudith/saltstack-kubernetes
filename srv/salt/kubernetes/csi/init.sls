{%- from "kubernetes/map.jinja" import charts with context -%}

include:
{%- if pillar.kubernetes.master.storage.get('rook_ceph', {'enabled': False}).enabled %}
  - kubernetes.csi.rook-ceph
{%- endif -%}
{%- if pillar.kubernetes.master.storage.get('rook_minio', {'enabled': False}).enabled %}
  - kubernetes.csi.rook-minio
{%- endif -%}