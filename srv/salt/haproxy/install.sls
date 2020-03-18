{%- from tpldir ~ "/map.jinja" import haproxy with context -%}


haproxy:
  require:
    - pkg: haproxy-repo
  pkg.installed:
    - version: "{{ haproxy.version | safe }}"