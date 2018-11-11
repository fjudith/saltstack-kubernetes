# Master (a.k.a Control Plane Node)

Master is the role for servers dedicated to manage the Kubernetes cluster control plane, which include the `kube-apiserver`, `kube-scheduler` and `kube-controller-manager`.

A Master is a Kubernetes node registered with the `taint node-role.kubernetes.io/master=:NoSchedule` to only accept the scheduling of [Daemonsets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) or Pods configured with the following [Toleration](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) in the deployment specs.

```yaml
spec:
  replicas: 2
...
    spec:
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
```

The following certificates are required for the TLS mutual authentication and encryption with the Kubernetes control-plane (i.e Kubernetes masters).

* CA certificate: `/etc/kubernetes/ssl/ca.pem`
* CA private-key: `/etc/kubernetes/ssl/ca-key.pem`
* Server certificate: `/etc/kubernetes/ssl/master.pem`
* Server private key: `/etc/kubernetes/ssl/master-key.pem`
* Kube-Proxy certificate: `/etc/kubernetes/ssl/kube-proxy.pem`
* Kube-Proxy private key: `/etc/kubernetes/ssl/kube-proxy-key.pem`
* Flannel certificate: `/etc/kubernetes/ssl/flanneld.pem`
* Flannel private key: `/etc/kubernetes/ssl/flanneld-key.pem`
* Kube-ApiServer certificate: `/etc/kubernetes/ssl/kube-apiserver.pem`
* Kube-ApiServer private key: `/etc/kubernetes/ssl/kube-apiserver-key.pem`
* Kube-Controller-Manager certificate: `/etc/kubernetes/ssl/kube-controller-manager.pem`
* Kube-Controller-Manager private key: `/etc/kubernetes/ssl/kube-controller-manager-key.pem`
* Kube-Scheduler certificate: `/etc/kubernetes/ssl/kube-scheduler.pem`
* Kube-Scheduler private key: `/etc/kubernetes/ssl/kube-scheduler-key.pem`
* Service Account certificate: `/etc/kubernetes/ssl/service-account.pem`
* Service Account private key: `/etc/kubernetes/ssl/service-account-key.pem`
* Kubernetes Dashboard certificate: `/etc/kubernetes/ssl/service-account.pem`
* Kubernetes Dashboard private key: `/etc/kubernetes/ssl/service-account-key.pem`

---

Master configuration is enabled by the following pillar data.

```yaml
kubernetes:
  master:
    service_addresses: 10.3.0.0/24
    members:
      - host: 172.17.4.101
        name: master01
      - host: 172.17.4.102
        name: master02
      - host: 172.17.4.103
        name: master03
```

To manually configure a Master and deploy the Kubernetes [cluster addons](./features.md) run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:master state.apply
```

## Troubleshooting

Check the cluster components statues.

```bash
kubectl get componentstatus
```

```text
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-2               Healthy   {"health": "true"}
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
```

Check the nodes/kubelets registered in the cluster.

```bash
kubectl get nodes -o wide
```

```text
NAME       STATUS   ROLES          AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   Ready    master         14d   v1.12.2   172.17.4.101   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
master02   Ready    master         14d   v1.12.2   172.17.4.102   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
master03   Ready    master         14d   v1.12.2   172.17.4.103   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
node01     Ready    node           14d   v1.12.2   172.17.4.201   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
node02     Ready    node           14d   v1.12.2   172.17.4.202   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
node03     Ready    node           14d   v1.12.2   172.17.4.203   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
node04     Ready    node           14d   v1.12.2   172.17.4.204   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
node05     Ready    node           14d   v1.12.2   172.17.4.205   <none>        Ubuntu 18.04 LTS     4.15.0-22-generic   containerd://1.2.0
node06     Ready    node           14d   v1.12.2   172.17.4.206   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
proxy01    Ready    ingress,node   14d   v1.12.2   172.17.4.251   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
proxy02    Ready    ingress,node   14d   v1.12.2   172.17.4.252   <none>        Ubuntu 18.04.1 LTS   4.15.0-34-generic   containerd://1.2.0
```


Check if Kube-Apiserver is running.

```bash
salt -G role:master cmd.run 'systemctl --lines 0 status kube-api-server'
```

```text
...
master02:
    * kube-apiserver.service - Kubernetes API Server
       Loaded: loaded (/etc/systemd/system/kube-apiserver.service; enabled; vendor preset: enabled)
       Active: active (running) since Sat 2018-11-10 23:59:37 CET; 1h 11min ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/admin/kubelet-authentication-authorization
     Main PID: 31261 (kube-apiserver)
        Tasks: 10 (limit: 2299)
       CGroup: /system.slice/kube-apiserver.service
               `-31261 /usr/local/bin/kube-apiserver --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota --advertise-address=172.17.4.102 --allow-privileged=true --anonymous-auth=false --apiserver-count=3 --audit-log-maxage=30 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-path=/var/log/kube-audit/audit.log --audit-policy-file=/etc/kubernetes/audit-policy.yaml --authorization-mode=Node,RBAC --bind-address=0.0.0.0 --client-ca-file=/etc/kubernetes/ssl/ca.pem --enable-bootstrap-token-auth --enable-swagger-ui=true --storage-backend=etcd3 --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/apiserver.pem --etcd-keyfile=/etc/kubernetes/ssl/apiserver-key.pem --etcd-servers=https://172.17.4.51:2379,https://172.17.4.52:2379,https://172.17.4.53:2379 --event-ttl=1h --experimental-encryption-provider-config=/etc/kubernetes/encryption-config.yaml --insecure-bind-address=127.0.0.1 --kubelet-certificate-authority=/etc/kubernetes/ssl/ca.pem --kubelet-client-certificate=/etc/kubernetes/ssl/apiserver.pem --kubelet-client-key=/etc/kubernetes/ssl/apiserver-key.pem --kubelet-https=true --runtime-config=api/all --runtime-config=extensions/v1beta1/networkpolicies=true --service-account-key-file=/etc/kubernetes/ssl/service-account.pem --service-cluster-ip-range=10.3.0.0/24 --service-node-port-range=30000-50000 --storage-media-type=application/json --tls-cert-file=/etc/kubernetes/ssl/apiserver.pem --tls-private-key-file=/etc/kubernetes/ssl/apiserver-key.pem --token-auth-file=/etc/kubernetes/token.csv --v=2
master03:
    * kube-apiserver.service - Kubernetes API Server
       Loaded: loaded (/etc/systemd/system/kube-apiserver.service; enabled; vendor preset: enabled)
       Active: active (running) since Sat 2018-11-10 23:59:28 CET; 1h 12min ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/admin/kubelet-authentication-authorization
     Main PID: 3506 (kube-apiserver)
        Tasks: 10 (limit: 2299)
       CGroup: /system.slice/kube-apiserver.service
               `-3506 /usr/local/bin/kube-apiserver --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota --advertise-address=172.17.4.103 --allow-privileged=true --anonymous-auth=false --apiserver-count=3 --audit-log-maxage=30 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-path=/var/log/kube-audit/audit.log --audit-policy-file=/etc/kubernetes/audit-policy.yaml --authorization-mode=Node,RBAC --bind-address=0.0.0.0 --client-ca-file=/etc/kubernetes/ssl/ca.pem --enable-bootstrap-token-auth --enable-swagger-ui=true --storage-backend=etcd3 --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/apiserver.pem --etcd-keyfile=/etc/kubernetes/ssl/apiserver-key.pem --etcd-servers=https://172.17.4.51:2379,https://172.17.4.52:2379,https://172.17.4.53:2379 --event-ttl=1h --experimental-encryption-provider-config=/etc/kubernetes/encryption-config.yaml --insecure-bind-address=127.0.0.1 --kubelet-certificate-authority=/etc/kubernetes/ssl/ca.pem --kubelet-client-certificate=/etc/kubernetes/ssl/apiserver.pem --kubelet-client-key=/etc/kubernetes/ssl/apiserver-key.pem --kubelet-https=true --runtime-config=api/all --runtime-config=extensions/v1beta1/networkpolicies=true --service-account-key-file=/etc/kubernetes/ssl/service-account.pem --service-cluster-ip-range=10.3.0.0/24 --service-node-port-range=30000-50000 --storage-media-type=application/json --tls-cert-file=/etc/kubernetes/ssl/apiserver.pem --tls-private-key-file=/etc/kubernetes/ssl/apiserver-key.pem --token-auth-file=/etc/kubernetes/token.csv --v=2
```

Check if Kube-Controller-Manager is running.

```bash
salt -G role:master cmd.run 'systemctl --lines 0 status kube-controller-manager'
```

```text
...
master02:
    * kube-controller-manager.service - Kubernetes Controller Manager
       Loaded: loaded (/etc/systemd/system/kube-controller-manager.service; enabled; vendor preset: enabled)
       Active: active (running) since Sun 2018-11-11 00:05:49 CET; 1h 10min ago
         Docs: https://github.com/kubernetes/kubernetes
     Main PID: 32707 (kube-controller)
        Tasks: 6 (limit: 2299)
       CGroup: /system.slice/kube-controller-manager.service
               `-32707 /usr/local/bin/kube-controller-manager --address=0.0.0.0 --cluster-cidr=10.2.0.0/16 --allocate-node-cidrs=true --cluster-name=kubernetes --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem --feature-gates=RotateKubeletServerCertificate=true --flex-volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --leader-elect=true --node-monitor-grace-period=40s --node-monitor-period=5s --pod-eviction-timeout=5m0s --root-ca-file=/etc/kubernetes/ssl/ca.pem --service-account-private-key-file=/etc/kubernetes/ssl/service-account-key.pem --service-cluster-ip-range=10.3.0.0/24 --use-service-account-credentials=true --v=2
master03:
    * kube-controller-manager.service - Kubernetes Controller Manager
       Loaded: loaded (/etc/systemd/system/kube-controller-manager.service; enabled; vendor preset: enabled)
       Active: active (running) since Sun 2018-11-11 00:05:45 CET; 1h 10min ago
         Docs: https://github.com/kubernetes/kubernetes
     Main PID: 5078 (kube-controller)
        Tasks: 6 (limit: 2299)
       CGroup: /system.slice/kube-controller-manager.service
               `-5078 /usr/local/bin/kube-controller-manager --address=0.0.0.0 --cluster-cidr=10.2.0.0/16 --allocate-node-cidrs=true --cluster-name=kubernetes --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem --feature-gates=RotateKubeletServerCertificate=true --flex-volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig --leader-elect=true --node-monitor-grace-period=40s --node-monitor-period=5s --pod-eviction-timeout=5m0s --root-ca-file=/etc/kubernetes/ssl/ca.pem --service-account-private-key-file=/etc/kubernetes/ssl/service-account-key.pem --service-cluster-ip-range=10.3.0.0/24 --use-service-account-credentials=true --v=2
```

Check if Kube-Scheduler is running.

```bash
salt -G role:master cmd.run 'systemctl --lines 0 status kube-scheduler'
```

```text
...
master02:
    * kube-scheduler.service - Kubernetes Scheduler
       Loaded: loaded (/etc/systemd/system/kube-scheduler.service; enabled; vendor preset: enabled)
       Active: active (running) since Sun 2018-11-11 00:18:22 CET; 1h 0min ago
         Docs: https://github.com/kubernetes/kubernetes
     Main PID: 3101 (kube-scheduler)
        Tasks: 8 (limit: 2299)
       CGroup: /system.slice/kube-scheduler.service
               `-3101 /usr/local/bin/kube-scheduler --config=/var/lib/kube-scheduler/kube-scheduler-config.yaml --v=2
master03:
    * kube-scheduler.service - Kubernetes Scheduler
       Loaded: loaded (/etc/systemd/system/kube-scheduler.service; enabled; vendor preset: enabled)
       Active: active (running) since Sun 2018-11-11 00:18:21 CET; 1h 0min ago
         Docs: https://github.com/kubernetes/kubernetes
     Main PID: 7873 (kube-scheduler)
        Tasks: 8 (limit: 2299)
       CGroup: /system.slice/kube-scheduler.service
               `-7873 /usr/local/bin/kube-scheduler --config=/var/lib/kube-scheduler/kube-scheduler-config.yaml --v=2
```


Check if Kubelet is running.

```bash
salt -G role:master cmd.run 'systemctl --lines 0 status kubelet'
```

```text
...
master02:
    * kubelet.service - Kubernetes Kubelet
       Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
      Drop-In: /etc/systemd/system/kubelet.service.d
               `-0-containerd.conf
       Active: active (running) since Sun 2018-11-11 00:29:54 CET; 39min ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet
     Main PID: 5567 (kubelet)
        Tasks: 14 (limit: 2299)
       CGroup: /system.slice/kubelet.service
               `-5567 /usr/local/bin/kubelet --allow-privileged=true --config=/var/lib/kubelet/kubelet-config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --hostname-override=master02 --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --network-plugin=cni --node-labels=kubernetes.io/role=master,beta.kubernetes.io/fluentd-ds-ready=true --register-with-taints=node-role.kubernetes.io/master=:NoSchedule --volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --v=2
master03:
    * kubelet.service - Kubernetes Kubelet
       Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
      Drop-In: /etc/systemd/system/kubelet.service.d
               `-0-containerd.conf
       Active: active (running) since Sun 2018-11-11 00:29:51 CET; 39min ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet
     Main PID: 10324 (kubelet)
        Tasks: 14 (limit: 2299)
       CGroup: /system.slice/kubelet.service
               `-10324 /usr/local/bin/kubelet --allow-privileged=true --config=/var/lib/kubelet/kubelet-config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --hostname-override=master03 --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --network-plugin=cni --node-labels=kubernetes.io/role=master,beta.kubernetes.io/fluentd-ds-ready=true --register-with-taints=node-role.kubernetes.io/master=:NoSchedule --volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --v=2
```