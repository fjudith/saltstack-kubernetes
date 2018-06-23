{%- set etcdVersion = pillar['kubernetes']['etcd']['version'] -%}
{%- set etcdCount = pillar['kubernetes']['etcd']['count'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}

include:
  - node.cri.docker
  - node.cri.rkt

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
    - source: salt://etcd/etcd-wrapper
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
    - source: https://github.com/coreos/etcd/releases/download/{{ etcdVersion }}/etcd-{{ etcdVersion }}-linux-amd64.tar.gz
    - skip_verify: true
    - archive_format: tar

{# {% for key, ipaddr in pillar.get(['kubernetes']['etcd']['cluster']['etcd*'], {}).items() %}
etcd-certificate-archive:
  archive.extracted:
    - name: /var/lib/etcd/ssl
    - source: salt://certs/etcd-{{ ipaddr }}.tar
    - skip_verify: true
    - archive_format: tar
    - enforce_toplevel: false
{% endfor %} #}

/usr/bin/etcd:
  file.symlink:
    - target: /opt/etcd-{{ etcdVersion }}-linux-amd64/etcd
/usr/bin/etcdctl:
  file.symlink:
    - target: /opt/etcd-{{ etcdVersion }}-linux-amd64/etcdctl

{% if masterCount == 1 %}
/etc/systemd/system/etcd.service:
  file.managed:
    - source: salt://etcd/etcd.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% elif etcdCount == 3 %}
{# /etc/systemd/system/etcd.service:
  file.managed:
    - source: salt://etcd/etcd-cluster.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644 #}

/etc/systemd/system/etcd-member.service:
  file.managed:
    - source: salt://etcd/etcd-member.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% endif %}

etcd-member.service:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/etcd-member.service