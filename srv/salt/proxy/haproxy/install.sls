{% from tpldir ~ "/map.jinja" import haproxy with context %}

haproxy.install:
  pkg.installed:
    - name: {{ haproxy.package }}
{% if salt['pillar.get']('haproxy:require') %}
    - require:
{% for item in salt['pillar.get']('haproxy:require') %}
      - {{ item }}
{% endfor %}
{% endif %}