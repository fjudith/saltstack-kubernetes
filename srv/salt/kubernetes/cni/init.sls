{%- from "kubernetes/map.jinja" import common with context -%}

 /etc/cni:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/etc/cni/net.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

cni-latest-archive:
  archive.extracted:
    - name: /opt/cni/bin
    - source: {{ common.cni.source }}
    - source_hash: {{ common.cni.source_hash }}
    - archive_format: tar
    - if_missing: /opt/cni/bin/loopback

/etc/cni/net.d/99-loopback.conf:
  require:
    - file: /etc/cni/net.d
  file.managed:
    - source: salt://kubernetes/cni/99-loopback.conf
    - user: root
    - group: root
    - mode: "0644"


{% if common.cni.provider == "cilium" %}
/sys/fs/bpf:
  mount.mounted:
    - device: bpffs
    - fstype: bpf
    - mkmnt: True
{% endif %}