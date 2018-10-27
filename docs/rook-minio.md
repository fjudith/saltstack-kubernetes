# Rook-Minio

Rook Minio deployment is enabled by the following pillar data.

> `username` and `password` are base64 values generated using the following command line: 
> `echo -n 'THIS_IS_MY_VALUE' | base64`

```yaml
kubernetes:
  master:
    storage:
      rook_minio:
        enabled: True
        image: rook/minio:v0.8.3
        username: VEhJU19JU19NWV9WQUxVRQ==
        password: VEhJU19JU19NWV9WQUxVRQ==
```

To manually deploy Rook Minio run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:master state.apply kubernetes.csi.rook.minio
```
## Troubleshooting

Check if Rook Minio Operator is running.

```bash
kubectl -n rook-minio get pod
```



```text
NAME                                       READY   STATUS    RESTARTS   AGE
pod/rook-minio-operator-5db6758547-rqrmg   1/1     Running   0          27m
```

Check if Rook Minio storage has been created by **rook-minio-operator**.

```bash
kubectl -n rook-minio get pod,svc,pvc
```

```text
NAME             READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE
pod/my-store-0   1/1     Running   0          28m   10.2.192.14   node04   <none>
pod/my-store-1   1/1     Running   0          28m   10.2.96.12    node03   <none>
pod/my-store-2   1/1     Running   0          28m   10.2.128.15   node01   <none>
pod/my-store-3   1/1     Running   0          27m   10.2.80.14    node05   <none>

NAME                    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE    SELECTOR
service/minio-service   NodePort    10.3.0.105   <none>        9000:34393/TCP   128m   app=minio
service/my-store        ClusterIP   None         <none>        9000/TCP         28m    app=minio

NAME                                    STATUS   VOLUME                                     CAPACITY
ACCESS MODES   STORAGECLASS      AGE
persistentvolumeclaim/data-my-store-0   Bound    pvc-59607958-d9f1-11e8-a40c-96000012e4d2   10G
RWO            rook-ceph-block   28m
persistentvolumeclaim/data-my-store-1   Bound    pvc-5f1fd566-d9f1-11e8-a40c-96000012e4d2   10G
RWO            rook-ceph-block   28m
persistentvolumeclaim/data-my-store-2   Bound    pvc-68dc813e-d9f1-11e8-a40c-96000012e4d2   10G
RWO            rook-ceph-block   28m
persistentvolumeclaim/data-my-store-3   Bound    pvc-6d666f14-d9f1-11e8-a40c-96000012e4d2   10G
RWO            rook-ceph-block   27m
```

If Persistent Volume Claims are in status **Unbound**. This likely means that **rook-ceph-block** is not configured as the default storage class.

```bash
kubectl get storageclass
```

```text
NAME                        PROVISIONER          AGE
rook-ceph-block   ceph.rook.io/block   139m
```

Run the following following command lines to set `rook-ceph-block` as the default storage class.

```bash
kubectl patch storageclass rook-ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl get storageclass
```

```text
NAME                        PROVISIONER          AGE
rook-ceph-block (default)   ceph.rook.io/block   141m
```