{%- from tpldir ~ "/map.jinja" import haproxy with context -%}

{{  haproxy.config_file }}:
  file.managed:
    - source: salt://{{ tpldir }}/templates/haproxy.cfg.j2
    - user: {{ haproxy.user }}
    - group: {{ haproxy.group }}
    - mode: "0644"
    - template: jinja
    - watch_in: 
      - service: haproxy.service
    - context:
      tpldir: {{ tpldir }}
    {% if haproxy.overwrite == False %}
    - unless:
      - test -e {{ haproxy.config_file }}
    {% endif %}