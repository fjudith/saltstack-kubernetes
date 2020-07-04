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
{%- set mount_name = file.lun_name %}
/mnt/{{ mount_name }}:
  require:
    - service: tgt.service
  mount.unmounted:
    - device: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1
    - persist: True

/etc/iscsi/nodes/{{ loopback_iscsi.iqn }}:{{ file.lun_name }}:
  file.absent:
    - require:
      - service: tgt.service

{{ loopback_iscsi.path }}/{{ file.name }}:
  file.absent:
    - require:
      - service: tgt.service

{%- endfor %}