{%- from "kubernetes/map.jinja" import etcd with context -%}

/etc/etcd:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/usr/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/var/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

etcd-latest-archive:
  archive.extracted:
    - name: /opt/
    - source: https://github.com/coreos/etcd/releases/download/{{ etcd.version }}/etcd-{{ etcd.version }}-linux-amd64.tar.gz
    - skip_verify: true
    - archive_format: tar

etcd-install:
  service.dead:
    - name: etcd.service
    - watch:
      - archive: etcd-latest-archive
    - unless: cmp -s /usr/bin/etcd /opt/etcd-{{ etcd.version }}-linux-amd64/etcd
  file.copy:
    - name: /usr/bin/etcd
    - source: /opt/etcd-{{ etcd.version }}-linux-amd64/etcd
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: etcd-latest-archive
    - unless: cmp -s /usr/bin/etcd /opt/etcd-{{ etcd.version }}-linux-amd64/etcd

etcdctl-install:
  file.copy:
    - name: /usr/bin/etcdctl
    - source: /opt/etcd-{{ etcd.version }}-linux-amd64/etcdctl
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: etcd-latest-archive
    - unless: cmp -s /usr/bin/etcdctl /opt/etcd-{{ etcd.version }}-linux-amd64/etcdctl

/etc/systemd/system/etcd-member.service:
  file.managed:
    - source: salt://kubernetes/role/etcd/templates/etcd-member.service.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"

etcd-member.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/etcd-member.service
    - enable: True