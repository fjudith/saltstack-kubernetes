{%- from "kubernetes/map.jinja" import common with context -%}

 /etc/cni:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/etc/cni/net.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

cni-latest-archive:
  archive.extracted:
    - name: /opt/cni/bin
    - source: https://github.com/containernetworking/plugins/releases/download/{{ common.cni.version }}/cni-plugins-amd64-{{ common.cni.version }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/cni/bin/loopback

{% if common.cni.provider == "weave" %}
/etc/cni/net.d/00-weave.conflist:
    file.managed:
    - require:
      - file: /etc/cni/net.d
    - source: salt://kubernetes/cni/weave/00-weave.conflist
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% endif %}

/etc/cni/net.d/99-loopback.conf:
  require:
    - file: /etc/cni/net.d
  file.managed:
    - source: salt://kubernetes/cni/99-loopback.conf
    - user: root
    - group: root
    - mode: 644