check-etcd-members:
  cmd.run:
    - name: |
        alias ec="ETCDCTL_API=3 etcdctl --cacert /etc/etcd/pki/ca.crt --cert /etc/etcd/pki/server.crt --key /etc/etcd/pki/server.key"
        ec member list