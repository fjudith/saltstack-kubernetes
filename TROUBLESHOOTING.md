# Troubleshooting


## etcd single-node heath

```bash
curl -L --noproxy '*' --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem https://172.16.4.51:2379/health
curl -L --noproxy '*' --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem https://172.16.4.52:2379/health
curl -L --noproxy '*' --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem https://172.16.4.53:2379/health
```

## etcd cluster health

```bash
export ETCDCTL_API=3
etcdctl endpoint health
etcdctl member list
etcdctl check perf
```

## Terminate salt Job

```bash
salt-run jobs.list_jobs
salt '*' saltutil.term_job <job id>
```

### Listen salt event bus

```bash
salt-run state.event pretty=True
```