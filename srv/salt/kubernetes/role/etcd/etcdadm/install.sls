# -*- coding: utf-8 -*-
# vim: ft=jinja

{% from tpldir ~ "/map.jinja" import etcdadm with context %}

/opt/etcdadm-linux-amd64-v{{ etcdadm.version }}:
  file.managed:
    - source: https://github.com/kubernetes-sigs/etcdadm/releases/download/v{{ etcdadm.version }}/etcdadm-linux-amd64
    - source_hash: {{ etcdadm.source_hash }}
    - mode: "0755"
    - user: root
    - group: root
    - if_missing: /opt/etcdadm-linux-amd64-v{{ etcdadm.version }}

/usr/local/bin/etcdadm:
  file.symlink:
    - target: /opt/etcdadm-linux-amd64-v{{ etcdadm.version }}

etcd-latest-archive:
  archive.extracted:
    - name: /opt/
    - source: https://github.com/etcd-io/etcd/releases/download/v{{ etcdadm.client_version }}/etcd-v{{ etcdadm.client_version }}-linux-amd64.tar.gz
    - skip_verify: true
    - archive_format: tar

etcdctl:
  file.copy:
    - name: /usr/bin/etcdctl
    - source: /opt/etcd-v{{ etcdadm.client_version }}-linux-amd64/etcdctl
    - mode: "0555"
    - user: root
    - group: root
    - force: true
    - require:
      - archive: etcd-latest-archive
    - unless: cmp -s /usr/bin/etcdctl /opt/etcd-v{{ etcdadm.client_version }}-linux-amd64/etcdctl