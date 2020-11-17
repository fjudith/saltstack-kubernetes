{%- from tpldir ~ "/map.jinja" import envoy with context -%}

/etc/envoy:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/envoy/envoy.yaml:
  file.managed:
    - require:
        - file: /etc/envoy
    - source: salt://{{ tpldir }}/templates/envoy.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - watch_in:
      - service: envoy.service
    - context:
        tpldir: {{ tpldir }}
    {% if envoy.overwrite == False %}
    - unless:
      - test -e /etc/envoy/envoy.yaml
    {% endif %}
