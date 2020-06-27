{%- from tpldir ~ "/map.jinja" import loopback_iscsi with context -%}

open-iscsi.service:
  service.dead

tgt.service:
  service.dead

/etc/tgt/conf.d/loopback-iscsi.conf:
  file.absent:
    - require:
        - service: tgt.service

{%- for file in loopback_iscsi.files %}
/etc/iscsi/nodes/{{ loopback_iscsi.iqn }}:{{ file.lun_name }}:
  file.absent:
    - require:
      - service: tgt.service

{{ loopback_iscsi.path }}/{{ file.name }}:
  file.absent:
    - require:
      - service: tgt.service
{%- endfor %}