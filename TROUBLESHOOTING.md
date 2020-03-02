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
cat << EOF > gource.cfg
[display]
viewport=1280x720

[gource]
auto-skip-seconds=0.01
camera-mode=overview
#default-user-image=person.png
font-colour=ff7600
hide=progress
highlight-colour=ffe980
dir-colour=d5eaff
#highlight-dirs=true
highlight-users=true
key=true
seconds-per-day=0.1
#seconds-per-day=0.01
stop-at-end=true
time-scale=1.2
user-image-dir=.git/avatar/
#user-scale=8
user-scale=1
EOF

FILENAME=$(basename $(pwd)) && \
gource --start-date '2018-05-22 00:00:00' --hide filenames -c 2 --load-config gource.cfg --max-user-speed 100 -r 25 -o ${FILENAME}.ppm && \
sleep 10 && \
</dev/null ffmpeg -y \
    -r 60 \
    -f image2pipe -vcodec ppm -i ${FILENAME}.ppm \
    -filter:v "setpts=1.25*PTS" -vcodec libx264 \
    -preset slow -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 \
    ${FILENAME}.x264.mp4 && \
    rm -f ${FILENAME}.ppm
```

## Listen salt event bus

```bash
salt-run state.event pretty=True
```


## Unable to add a new service to be monitored with kube-prometheus

https://github.com/coreos/prometheus-operator/issues/731


## Force deletion of a stuck namespace

Start proxy.

```bash
kubectl proxy
```

```bash
NAMESPACE="anoying namespace"
kubectl get namespace ${NAMESPACE} -o json > tmp.json && \
sed -i 's#\"kubernetes\"##g' tmp.json && \
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://localhost:8001/api/v1/namespaces/${NAMESPACE}/finalize && \
rm -f tmp.json
```

## Force deletion of a stuck persistent volume

```bash
PV_NAME="annoying persistentvolume"
kubectl patch pv ${PV_NAME}  -p '{"metadata":{"finalizers":null}}'
```

## Restore kubadmo configuration

The folloing commands aims to restore the configuration required for further control-plane nodes to join when the 24 hours grace period expired.

Run the following commands from the server that ran the initial `kubeadm init` phase.

```bash
kubeadm init phase bootstrap-token --config kubeadm-config.yaml
kubeadm init phase upload-certs --config kubeadm-config.yaml --upload-certs
```
