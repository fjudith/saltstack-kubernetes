/var/lib/etcd:
  file.absent

/var/lib/etcd/member:
  file.absent

/etc/etcd:
  file.absent

stop-etcd:
  service.dead:
    - name: etcd.service

disable-etcd:
  service.disabled:
    - require:
      - service: stop-etcd
    - name: etcd.service