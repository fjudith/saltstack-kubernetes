{%- from tpldir ~ "/map.jinja" import loopback_iscsi with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}


{%- for file in loopback_iscsi.files %}
{%- set mount_name = file.lun_name %}
{# mklabel-{{ mount_name }}:
  module.run:
    - watch:
      - service: open-iscsi.service
    - partition.mklabel:
      - device: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1
      - label_type: msdos

mkpart-{{ mount_name }}:
  module.run:
    - watch:
      - module: mklabel-{{ mount_name }}
    - partition.mkpart:
      - device: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1
      - fs_type: {{ file.fs_type }}
      - start: 0%
      - end: 100%
      - part_type: primary

mkfs-{{ mount_name }}:
  module.run:
    - watch:
      - module: mkpart-{{ mount_name }}
    - extfs.mkfs:
      - device: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1-part1
      - fs_type: {{ file.fs_type }} 

/mnt/{{ mount_name }}:
  require:
    - module: mkfs-{{ mount_name }}
  mount.mounted:
    - device: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1-part1
    - fstype: {{ file.fs_type }}
    - persist: True
    - mkmnt: True #}

mkfs-{{ mount_name }}:
  blockdev.formatted:
    - name: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1
    - fs_type: {{ file.fs_type }}
    - unless: blkid /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1

/mnt/{{ mount_name }}:
  require:
    - blockdev: mkfs-{{ mount_name }}
  mount.mounted:
    - device: /dev/disk/by-path/ip-{{ loopback_iscsi.initiator_address }}:{{ loopback_iscsi.initiator_port }}-iscsi-iqn.0000-00.target.local:{{ mount_name }}-lun-1
    - fstype: {{ file.fs_type }}
    - persist: True
    - mkmnt: True

{%- endfor %}
