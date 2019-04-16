{%- from "kubernetes/map.jinja" import etcd with context -%}

/etc/etcd:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/usr/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/var/lib/coreos:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/usr/bin/mkdir:
  file.symlink:
    - target: /bin/mkdir

/usr/bin/bash:
  file.symlink:
    - target: /bin/bash

/usr/lib/coreos/etcd-wrapper:
  file.managed:
    - source: salt://kubernetes/role/etcd/scripts/etcd-wrapper
    - user: root
    - template: jinja
    - group: root
    - mode: 755

{# /etc/etcd/etcd-key.pem:
  file.symlink:
    - target: /var/lib/etcd/ssl/etcd-key.pem
/etc/etcd/etcd.pem:
  file.symlink:
    - target: /var/lib/etcd/ssl/etcd.pem
/etc/etcd/ca.pem:
  file.symlink:
    - target: /var/lib/etcd/ssl/ca.pem #}

etcd-latest-archive:
  archive.extracted:
    - name: /opt/
    - source: https://github.com/coreos/etcd/releases/download/{{ etcd.version }}/etcd-{{ etcd.version }}-linux-amd64.tar.gz
    - skip_verify: true
    - archive_format: tar

/usr/bin/etcd:
  file.symlink:
    - target: /opt/etcd-{{ etcd.version }}-linux-amd64/etcd

/usr/bin/etcdctl:
  file.symlink:
    - target: /opt/etcd-{{ etcd.version }}-linux-amd64/etcdctl

/etc/systemd/system/etcd-member.service:
  file.managed:
    - source: salt://kubernetes/role/etcd/templates/etcd-member.service.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

etcd-member.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/etcd-member.service
    - enable: True