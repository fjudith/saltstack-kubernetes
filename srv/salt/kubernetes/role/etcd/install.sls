# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import etcd with context %}

etcd-latest-archive:
  archive.extracted:
    - name: /opt/
    - source: https://github.com/etcd-io/etcd/releases/download/v{{ etcd.version }}/etcd-v{{ etcd.version }}-linux-amd64.tar.gz
    - skip_verify: true
    - archive_format: tar

etcd:
  service.dead:
    - name: etcd.service
    - watch:
      - archive: etcd-latest-archive
    - unless: cmp -s /usr/bin/etcd /opt/etcd-v{{ etcd.version }}-linux-amd64/etcd
  file.copy:
    - name: /usr/bin/etcd
    - source: /opt/etcd-v{{ etcd.version }}-linux-amd64/etcd
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: etcd-latest-archive
    - unless: cmp -s /usr/bin/etcd /opt/etcd-v{{ etcd.version }}-linux-amd64/etcd

etcdctl:
  file.copy:
    - name: /usr/bin/etcdctl
    - source: /opt/etcd-v{{ etcd.version }}-linux-amd64/etcdctl
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: etcd-latest-archive
    - unless: cmp -s /usr/bin/etcdctl /opt/etcd-v{{ etcd.version }}-linux-amd64/etcdctl

/etc/systemd/system/etcd.service:
  file.managed:
    - source: salt://{{ tpldir }}/files/etcd.service
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

etcd.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/etcd.service
      - file: /etc/etcd/etcd.env
    - enable: True
    - reload: True