# Node (a.k.a Workload Node)

Node is the role for servers dedicated to run both applications workload and persistent storage providers.

A Node is labeled with the `role=storage-node` to allow the scheduling of [Rook-Ceph](https://rook.io) distributed storage [Daemonsets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) that use the following [Node Selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) in their specs.

```yaml
spec:
  replicas: 2
...
    spec:
      nodeSelector:
        role: "storage-node"
```

The following certificates are required for the TLS mutual authentication and encryption with the Kubernetes control-plane (i.e Kubernetes masters).

* CA certificate: `/etc/kubernetes/ssl/ca.pem`
* Server certificate: `/etc/kubernetes/ssl/node.pem`
* Server private key: `/etc/kubernetes/ssl/node-key.pem`
* Kube-Proxy certificate: `/etc/kubernetes/ssl/kube-proxy.pem`
* Kube-Proxy private key: `/etc/kubernetes/ssl/kube-proxy-key.pem`
* Flannel certificate: `/etc/kubernetes/ssl/flanneld.pem`
* Flannel private key: `/etc/kubernetes/ssl/flanneld-key.pem`

---

Node configuration does not involes any specific pillar data.

To manually configure a Node run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:node state.apply
```

## Troubleshooting

Check if Kubelet is running.

```bash
salt -G role:node cmd.run 'systemctl --lines 0 status kubelet'
```

```text
...
node05:
    * kubelet.service - Kubernetes Kubelet
       Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
      Drop-In: /etc/systemd/system/kubelet.service.d
               `-0-containerd.conf
       Active: active (running) since Mon 2018-11-05 08:13:22 CET; 5 days ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet
     Main PID: 1624 (kubelet)
        Tasks: 26 (limit: 4915)
       CGroup: /system.slice/kubelet.service
               `-1624 /usr/local/bin/kubelet --allow-privileged=true --config=/var/lib/kubelet/kubelet-config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --hostname-override=node05 --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --network-plugin=cni --node-labels=kubernetes.io/role=node,beta.kubernetes.io/fluentd-ds-ready=true,role=storage-node --volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --v=2
node06:
    * kubelet.service - Kubernetes Kubelet
       Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
      Drop-In: /etc/systemd/system/kubelet.service.d
               `-0-containerd.conf
       Active: active (running) since Mon 2018-11-05 08:13:32 CET; 5 days ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet
     Main PID: 1627 (kubelet)
        Tasks: 36 (limit: 4915)
       CGroup: /system.slice/kubelet.service
               `-1627 /usr/local/bin/kubelet --allow-privileged=true --config=/var/lib/kubelet/kubelet-config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --hostname-override=node06 --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --network-plugin=cni --node-labels=kubernetes.io/role=node,beta.kubernetes.io/fluentd-ds-ready=true,role=storage-node --volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --v=2
```