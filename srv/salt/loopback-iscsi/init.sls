{%- from "kubernetes/map.jinja" import storage with context -%}

include:
  - .osprep
  - .config
  - .install
  # - .label
  {%- if storage.get('longhorn', {'enabled': False}).enabled %}
  - .mount
  {%- endif %}