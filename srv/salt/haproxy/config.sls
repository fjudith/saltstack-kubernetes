{% from tpldir ~ "/map.jinja" import haproxy with context %}

{% set config_file = salt['pillar.get']('haproxy:config_file_path', haproxy.config_file) %}
haproxy.config:
 file.managed:
   - name: {{ config_file }}
   - source: {{ haproxy.config_file_source }}
   - template: jinja
   - user: {{ haproxy.user }}
   - group: {{ haproxy.group }}
   - mode: "0644"
   - require_in:
     - service: haproxy.service
   - watch_in:
     - service: haproxy.service
   {% if salt['pillar.get']('haproxy:overwrite', default=True) == False %}
   - unless:
     - test -e {{ config_file }}
   {% endif %}