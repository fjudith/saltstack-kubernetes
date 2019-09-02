{%- from "kubernetes/map.jinja" import common with context -%}

cri-tools-archive:
  archive.extracted:
    - name: /usr/local/bin
    - source: https://github.com/kubernetes-incubator/cri-tools/releases/download/v{{ common.cri.crictl_version }}/crictl-v{{ common.cri.crictl_version }}-linux-amd64.tar.gz
    - skip_verify: true
    - archive_format: tar
    - enforce_toplevel: false

/etc/crictl.yaml:
  file.managed:
    - source: salt://kubernetes/cri/crictl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/usr/local/bin/runc:
  file.managed:
    - source: https://github.com/opencontainers/runc/releases/download/v{{ common.cri.runc_version }}/runc.amd64
    - source_hash: 0a9ac20ee52b6084ad161d516cc4e6248c5fd0cdf1fd4a7ac27f5243675632f9
    - user: root
    - group: root
    - mode: 755

/usr/bin/runc:
  file.symlink:
    - target: /usr/local/bin/runc
