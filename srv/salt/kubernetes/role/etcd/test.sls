test-etcd-members:
  cmd.wait:
    - name: |
        systemctl restart etcd.service

        sleep {{ range(10, 30) | random }}

        alias ec="ETCDCTL_API=3 etcdctl --cacert /etc/etcd/pki/ca.crt --cert /etc/etcd/pki/server.crt --key /etc/etcd/pki/server.key"
        ec member list
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10