{%- from "kubernetes/map.jinja" import storage with context -%}

include:
  {%- if storage.get('rook_ceph', {'enabled': False}).enabled %}
  - kubernetes.csi.rook-ceph
  {%- endif %}
  {%- if storage.get('longhorn', {'enabled': False}).enabled %}
  - kubernetes.csi.longhorn
  {%- endif %}
  {%- if storage.get('openebs', {'enabled': False}).enabled %}
  - kubernetes.csi.openebs
  {%- endif %}
  {%- if storage.get('mayastor', {'enabled': False}).enabled %}
  - kubernetes.csi.mayastor
  {%- endif %}
  {%- if storage.get('portworx', {'enabled': False}).enabled %}
  - kubernetes.csi.portworx
  {%- endif %}
  {%- if storage.get('minio', {'enabled': False}).enabled %}
  - kubernetes.csi.minio
  {%- endif %}