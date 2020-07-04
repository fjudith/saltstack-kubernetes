{%- from "kubernetes/map.jinja" import storage with context -%}

include:
  - .osprep
  - .config
  - .install
  {%- if storage.get('longhorn', {'enabled': False}).enabled %}
  - .mount
  - .node_label
  {%- endif %}