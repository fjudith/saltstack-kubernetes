{%- from tpldir ~ "/map.jinja" import loopback_iscsi with context -%}


{%- for file in loopback_iscsi.files %}
mklabel-{{ file.lun_name }}:
  module.run:
    - watch:
      - service: open-iscsi.service
    - partition.mklabel:
      - device: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ file.lun_name }}-lun-1
      - label_type: gpt
{%- endfor %}