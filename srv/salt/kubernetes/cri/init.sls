{%- from "kubernetes/map.jinja" import common with context -%}

cri-tools-archive:
  archive.extracted:
    - name: /usr/local/bin
    - source: https://github.com/kubernetes-incubator/cri-tools/releases/download/{{ common.cri.version }}/crictl-{{ common.cri.version }}-linux-amd64.tar.gz
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
    - source: https://github.com/opencontainers/runc/releases/download/{{ common.cri.runc_version }}/runc.amd64
    - source_hash: eaa9c9518cc4b041eea83d8ef83aad0a347af913c65337abe5b94b636183a251
    - user: root
    - group: root
    - mode: 755 