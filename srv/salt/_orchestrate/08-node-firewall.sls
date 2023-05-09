{%- from "kubernetes/map.jinja" import storage with context -%}

{%- if storage.get('portworx', {'enabled': False}).enabled %}
compute_allow_portworx:
  salt.state:
    - tgt: 'G@role:node'
    - tgt_type: compound
    - sls: kubernetes.csi.portworx.firewall
{%- endif %}