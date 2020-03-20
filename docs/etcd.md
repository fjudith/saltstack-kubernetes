# Etcd
Etcd is a role for servers dedicated to run the Etcd cluster used as backing store for all Kubernetes cluster data.


The following certificates are required for the mutual TLS encryption of the communications between the cluster members and from etcd clients (e.g. kube-apiserver).

* CA certificate: `/etc/etcd/ssl/ca.pem`
* Server certificate: `/etc/etcd/ssl/etcd.pem`
* Server private key: `/etc/etcd/ssl/etcd-key.pem`

These certificates are generated during the Terraform process.

---

Etcd deployment is enabled by the following pillar data.

```yaml
kubernetes:
  etcd:
    host: 127.0.0.1
    members:
      - host: 172.17.4.51
        name: etcd01
      - host: 172.17.4.52
        name: etcd02
      - host: 172.17.4.53
        name: etcd03
    version: v3.2.24
```

To manually deploy Etcd run the following command line from the **Salt-Master** (i.e. edge01).

```bash
salt -G role:etcd state.apply kubernetes.role.etcd
```

## Troubleshooting

Check if Etcd cluster is running.

```bash
salt -G role:etcd cmd.run 'export ETCDCTL_API=3 && etcdctl member list'
```

```text
etcd01:
    33a74f00fedea6ee, started, etcd02, https://172.17.4.52:2380, https://172.17.4.52:2379
    62dc9a5fd5be0ae9, started, etcd01, https://172.17.4.51:2380, https://172.17.4.51:2379
    a27082674f3d6716, started, etcd03, https://172.17.4.53:2380, https://172.17.4.53:2379
etcd03:
    33a74f00fedea6ee, started, etcd02, https://172.17.4.52:2380, https://172.17.4.52:2379
    62dc9a5fd5be0ae9, started, etcd01, https://172.17.4.51:2380, https://172.17.4.51:2379
    a27082674f3d6716, started, etcd03, https://172.17.4.53:2380, https://172.17.4.53:2379
etcd02:
    33a74f00fedea6ee, started, etcd02, https://172.17.4.52:2380, https://172.17.4.52:2379
    62dc9a5fd5be0ae9, started, etcd01, https://172.17.4.51:2380, https://172.17.4.51:2379
    a27082674f3d6716, started, etcd03, https://172.17.4.53:2380, https://172.17.4.53:2379
```

Check if the Etcd cluster endpoint health.

```bash
salt -G role:etcd cmd.run 'export ETCDCTL_API=3 && etcdctl endpoint health'
```

```text
etcd01:
    127.0.0.1:2379 is healthy: successfully committed proposal: took = 1.873142ms
etcd03:
    127.0.0.1:2379 is healthy: successfully committed proposal: took = 2.006885ms
etcd02:
    127.0.0.1:2379 is healthy: successfully committed proposal: took = 2.880368ms
```

Check the Etcd cluster performance.

```bash
salt etcd01 cmd.run 'export ETCDCTL_API=3 && etcdctl check perf'
```

```text
...
PASS: Throughput is 146 writes/s
    Slowest request took too long: 1.490486s
    Stddev too high: 0.177526s
    FAIL
```