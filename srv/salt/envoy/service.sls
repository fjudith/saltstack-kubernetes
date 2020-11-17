{% from tpldir ~ "/map.jinja" import envoy with context %}

/etc/systemd/system/envoy.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/envoy.service
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

envoy.service:
{% if salt['pillar.get']('envoy:enable', True) %}
  service.running:
    - name: {{ envoy.service }}
    - enable: True
    - reload: False
    - require:
      - pkg: getenvoy-envoy
{% if salt['grains.get']('os_family') == 'Debian' %}
      - file: /etc/systemd/system/envoy.service
{% endif %}
{% else %}
  service.dead:
    - name: {{ envoy.service }}
    - enable: False
{% endif %}
