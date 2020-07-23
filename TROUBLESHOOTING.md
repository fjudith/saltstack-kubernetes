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

## Restore kubeadm configuration

The following commands aims to restore the configuration required for further control-plane nodes to join when the 24 hours grace period expired.

Run the following commands from the server that ran the initial `kubeadm init` phase.

```bash
kubeadm init phase bootstrap-token --config kubeadm-config.yaml
kubeadm init phase upload-certs --config kubeadm-config.yaml --upload-certs
```


## Wait for deployment to be completed

```bash
while [ "$(kubectl -n rook-edgefs-system get deployment rook-edgefs-operator -o jsonpath='{.status.conditions[0].reason}')" != "MinimumReplicasAvailable" ]
do
  printf '.' && sleep 5
done && \
kubectl -n rook-edgefs-system get deployment rook-edgefs-operator
```


### Remove Etcd member

It is required to manually remove the etcd member especially when the kubeadm join fails on `etcd` registration.

```bash
VERSION=3.4.3
MEMBER="node_name"
curl -L https://github.com/coreos/etcd/releases/download/v${VERSION}/etcd-v${VERSION}-linux-amd64.tar.gz | tar -xvzf - && \
mv etcd-v${VERSION}-linux-amd64/etcdctl /usr/local/bin/ && \
rm -rf etcd-v${VERSION}-linux-amd64 && \
alias ec="ETCDCTL_API=3 etcdctl --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key" && \
MEMBERID=$(ec member list | grep $MEMBER | awk -F ',' '{print($1)}') && \
ec member remove ${MEMBERID}
```



## Kuberbernetes upgrade procedure

The following procedure has been successfully tested for bugfix releases ugprade only.
Please refer to the kubeadm [upgrade documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) for minor and major upgrades.

```bash
VERSION="1.18.6"

salt -G role:master cmd.run "apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=${VERSION}-00 && apt-mark hold kubeadm"
salt -G role:master cmd.run "kubeadm version"

salt master01 cmd.run "kubectl drain master01 --ignore-daemonsets"
salt master01 cmd.run "sudo kubeadm upgrade apply v${VERSION} --ignore-preflight-errors=all -y -v5"
salt master01 cmd.run "kubectl uncordon master01"

salt master02 cmd.run "kubectl drain master02 --ignore-daemonsets"
salt master02 cmd.run "sudo kubeadm upgrade node -v5"
salt master02 cmd.run "kubectl uncordon master02"

salt master03 cmd.run "kubectl drain master03 --ignore-daemonsets"
salt master03 cmd.run "sudo kubeadm upgrade node -v5"
salt master03 cmd.run "kubectl uncordon master03"

salt -G role:master cmd.run "apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet=${VERSION}-00 kubectl=${VERSION}-00 && apt-mark hold kubelet kubectl"
salt -G role:master cmd.run "sudo systemctl daemon-reload && sudo systemctl restart kubelet"

salt -G role:edge cmd.run "apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet=${VERSION}-00 kubectl=${VERSION}-00 && apt-mark hold kubelet kubectl"
salt -G role:edge cmd.run "sudo systemctl daemon-reload && sudo systemctl restart kubelet"

salt -G role:node --batch '1' cmd.run "apt-mark unhold kubelet kubectl && apt-get update && apt-get install -y kubelet=${VERSION}-00 kubectl=${VERSION}-00 && apt-mark hold kubelet kubectl"
salt -G role:node --batch '1'  cmd.run "sudo systemctl daemon-reload && sudo systemctl restart kubelet"
```