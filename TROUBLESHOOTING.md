# Troubleshooting


## etcd single-node heath

```bash
curl -L --noproxy '*' --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem https://172.17.4.51:2379/health
curl -L --noproxy '*' --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem https://172.17.4.52:2379/health
curl -L --noproxy '*' --cacert /etc/etcd/ssl/ca.pem --cert /etc/etcd/ssl/etcd.pem --key /etc/etcd/ssl/etcd-key.pem https://172.17.4.53:2379/health
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

## Gource

```bash
FILENAME=$(basename $(pwd)) && \
gource --start-date '2018-05-22 00:00:00' --auto-skip-seconds 1 --seconds-per-day 1 -1280x720 -o ${FILENAME}.ppm && \
sleep 10 && \
</dev/null ffmpeg -y \
    -r 60 \
    -f image2pipe -vcodec ppm -i ${FILENAME}.ppm \
    -filter:v "setpts=0.25*PTS" -vcodec libx264 \
    -preset slow -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 \
    ${FILENAME}.x264.mp4 && \
    rm -f ${FILENAME}.ppm
```

### Listen salt event bus

```bash
salt-run state.event pretty=True
```


### Unable to add a new service to be monitored with kube-prometheus

https://github.com/coreos/prometheus-operator/issues/731


### Force deletion of stuck namespace

Start proxy.

```bash
kubctl proxy
```

```bash
NAMESPACE="anoying namespace"
kubectl get namespace ${NAMESPACE} -o json > tmp.json
sed -i 's#\"kubernetes\"##g' tmp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://localhost:8001/api/v1/namespaces/${NAMESPACE}/finalize
```