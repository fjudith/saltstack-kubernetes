{% from tpldir ~ "/defaults.yaml" import rawmap with context %}
{%- set tinp = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('tinyproxy')) %}

tinyproxy_config:
  file.managed:
    - name: {{ tinp.config }}
    - template: jinja
    - source: salt://tinyproxy/templates/tinyproxy.conf
    - watch_in:
      - service: tinyproxy