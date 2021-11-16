{%- from tpldir ~ "/map.jinja" import envoy with context -%}


getenvoy-envoy:
  require:
    - pkg: envoy-package-repository
  pkg.installed:
    - version: {{ envoy.version | safe }}

