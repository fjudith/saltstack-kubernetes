test-stop-etcd-service:
  service.dead:
    - name: etcd.service

test-etcd-members:
  service.running:
    - name: etcd.service
  cmd.wait:
    - watch:
      - service: etcd.service
    - name: |
        alias ec="ETCDCTL_API=3 etcdctl --cacert /etc/etcd/pki/ca.crt --cert /etc/etcd/pki/server.crt --key /etc/etcd/pki/server.key"
        ec member list