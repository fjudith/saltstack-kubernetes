{%- from tpldir ~ "/map.jinja" import loopback_iscsi with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}
{%- set hostname = salt['grains.get']('fqdn') -%}

longhorn-node-annotation:
  cmd.run:
    - user: root
    - name: |
        kubectl label node {{ hostname }} node.longhorn.io/create-default-disk=config --overwrite
        kubectl annotate node {{ hostname }} node.longhorn.io/default-disks-config='[{% for file in loopback_iscsi.files %}{"path":"/mnt/{{ file.lun_name }}","allowScheduling":true,"tags"["loopback-isci"]}{% if not loop.last %},{% endif %}{% endfor %}]' --overwrite
