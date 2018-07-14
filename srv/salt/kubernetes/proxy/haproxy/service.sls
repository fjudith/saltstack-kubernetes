{% from tpldir ~ "/map.jinja" import haproxy with context %}

haproxy.service:
{% if salt['pillar.get']('haproxy:enable', True) %}
  service.running:
    - name: {{ haproxy.service }}
    - enable: True
    - reload: True
    - require:
      - pkg: haproxy.install
{% if salt['grains.get']('os_family') == 'Debian' %}
      - file: haproxy.service
{% endif %}
{% else %}
  service.dead:
    - name: {{ haproxy.service }}
    - enable: False
{% endif %}
{% if salt['grains.get']('os_family') == 'Debian' %}
  file.replace:
    - name: /etc/default/haproxy
{% if salt['pillar.get']('haproxy:enabled', True) %}
    - pattern: ENABLED=0$
    - repl: ENABLED=1
{% else %}
    - pattern: ENABLED=1$
    - repl: ENABLED=0
{% endif %}
    - show_changes: True
{% endif %}