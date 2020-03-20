# Minio

Minio-Operator deployment is enabled by the following pillar data.

> `accesskey` and `secretkey` are base64 values generated using the following command line: 
> `echo -n 'THIS_IS_MY_VALUE' | base64`

```yaml
kubernetes:
  storage:
    rook_minio:
      enabled: True
      accesskey: minio
      secretkey: V3ry1ns3cur3P4ssword
```

To manually deploy Rook Minio run the following command line from the **Salt-Master** (i.e. edge01).

```bash
salt -G role:master state.apply kubernetes.csi.minio-operator
```

## Troubleshooting

Check if Rook Minio Operator is running.

```bash
kubectl -n minio-system -l name=minio-operator get po
```



```text
NAME                              READY   STATUS    RESTARTS   AGE
minio-operator-55d99988b9-v95lm   1/1     Running   0          52m
```

Check if Rook Minio storage has been created by **rook-minio-operator**.

```bash
kubectl -n minio get pod,svc,pvc
```

```text
NAME          READY   STATUS              RESTARTS   AGE
pod/minio-0   0/1     Running             0          14m
pod/minio-1   0/1     Running             0          14m
pod/minio-2   0/1     Running             0          14m
pod/minio-3   0/1     Running             0          14m

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/minio          ClusterIP   10.106.163.131   <none>        9000/TCP   14m
service/minio-hl-svc   ClusterIP   None             <none>        9000/TCP   14m

NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS
          AGE
persistentvolumeclaim/data-minio-0   Bound    pvc-c4ca6bf4-9183-4c54-9c38-516537e3413e   10Gi       RWO            edgefs-iscsi-csi-storageclass   14m
persistentvolumeclaim/data-minio-1   Bound    pvc-854769e9-95d0-47cf-9dc8-a3ab2eff5400   10Gi       RWO            edgefs-iscsi-csi-storageclass   14m
persistentvolumeclaim/data-minio-2   Bound    pvc-b8797841-f095-448d-92c0-fe26d6617c98   10Gi       RWO            edgefs-iscsi-csi-storageclass   14m
persistentvolumeclaim/data-minio-3   Bound    pvc-c75d8951-3651-4c57-8a3a-1a9f27e83327   10Gi       RWO            edgefs-iscsi-csi-storageclass   14m
```

If Persistent Volume Claims are in status **Unbound**. This likely means that **Default**  storage class is not configured.

```bash
kubectl get storageclass
```

```text
NAME                                      PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
edgefs-iscsi-csi-storageclass             io.edgefs.csi.iscsi            Delete          Immediate              false                  39m
edgefs-nfs-csi-storageclass               io.edgefs.csi.nfs              Delete          Immediate              false                  17m
local-storage                             kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  55m
```

Run the following following command lines to set `edgefs-iscsi-csi-storageclass` as the default storage class.

```bash
kubectl patch storageclass edgefs-iscsi-csi-storageclass -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl get storageclass
```

```text
NAME                                      PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
edgefs-iscsi-csi-storageclass (default)   io.edgefs.csi.iscsi            Delete          Immediate              false                  39m
edgefs-nfs-csi-storageclass               io.edgefs.csi.nfs              Delete          Immediate              false                  17m
local-storage                             kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  55m
```

If the persistent volume claim is hower **not boud**.
Run the following command to check the storage  class mapping logs.


```text
kubectl -n minio describe pvc data-minio-0
```