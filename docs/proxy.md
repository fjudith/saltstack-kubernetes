# edge (a.k.a Edge Gateway Node)

edge is a role for nodes dedicated to the inbound (Ingress) and outboud (Egress) traffic. In other words it allows to select a server the endorce the functions of an edge gateway and a perimeter load-balancer of the Kubernetes cluster.

edge is a basic Kubernetes node registered with the `taint node-role.kubernetes.io/ingress=:NoSchedule` and labeled with the role `node-role.kubernetes.io/ingress`, as such it only accepts the scheduling of [Daemonsets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) or Pods configured with to following [Toleration](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) and [Node Selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) in the deployment specs.

```yaml
spec:
  replicas: 2
...
    spec:
      tolerations:
        - key: node-role.kubernetes.io/ingress
          effect: NoSchedule
      nodeSelector:
        node-role.kubernetes.io/ingress: "true"
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

Proxy node configuration does not involes any pillar data.

To manually configure Proxy run the following command line from the **Salt-Master** (i.e. proxy01).

```bash
salt -G role:proxy state.apply
```

## Troubleshooting

Check if the HAproxy load-balancer is running.

```bash
salt -G role:proxy cmd.run 'systemctl --lines 0 status haproxy'
```

```text
proxy01:
    * haproxy.service - HAProxy Load Balancer
       Loaded: loaded (/lib/systemd/system/haproxy.service; enabled; vendor preset: enabled)
       Active: active (running) since Wed 2018-11-07 10:17:31 CET; 3 days ago
         Docs: man:haproxy(1)
               file:/usr/share/doc/haproxy/configuration.txt.gz
      Process: 1187 ExecStartPre=/usr/sbin/haproxy -f $CONFIG -c -q $EXTRAOPTS (code=exited, status=0/SUCCESS)
     Main PID: 1214 (haproxy)
        Tasks: 2 (limit: 2299)
       CGroup: /system.slice/haproxy.service
               |-1214 /usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
               `-1228 /usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid

proxy02:
    * haproxy.service - HAProxy Load Balancer
       Loaded: loaded (/lib/systemd/system/haproxy.service; enabled; vendor preset: enabled)
       Active: active (running) since Mon 2018-11-05 08:12:10 CET; 5 days ago
         Docs: man:haproxy(1)
               file:/usr/share/doc/haproxy/configuration.txt.gz
      Process: 1135 ExecStartPre=/usr/sbin/haproxy -f $CONFIG -c -q $EXTRAOPTS (code=exited, status=0/SUCCESS)
     Main PID: 1178 (haproxy)
        Tasks: 2 (limit: 2299)
       CGroup: /system.slice/haproxy.service
               |-1178 /usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
               `-1185 /usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid

```

Check if tiny proxy is running.

```bash
salt -G role:proxy cmd.run 'systemctl --lines 0 status tinyproxy'
```

```text
proxy01:
    * tinyproxy.service - Tinyproxy lightweight HTTP Proxy
       Loaded: loaded (/lib/systemd/system/tinyproxy.service; enabled; vendor preset: enabled)
       Active: active (running) since Wed 2018-11-07 10:17:31 CET; 3 days ago
         Docs: man:tinyproxy(8)
               man:tinyproxy.conf(5)
      Process: 1146 ExecStart=/usr/sbin/tinyproxy (code=exited, status=0/SUCCESS)
     Main PID: 1216 (tinyproxy)
        Tasks: 21 (limit: 2299)
       CGroup: /system.slice/tinyproxy.service
               |-1216 /usr/sbin/tinyproxy
               |-1230 /usr/sbin/tinyproxy
               |-1238 /usr/sbin/tinyproxy
               |-1240 /usr/sbin/tinyproxy
               |-1244 /usr/sbin/tinyproxy
               |-1245 /usr/sbin/tinyproxy
               |-1246 /usr/sbin/tinyproxy
               |-1247 /usr/sbin/tinyproxy
               |-1248 /usr/sbin/tinyproxy
               |-1249 /usr/sbin/tinyproxy
               |-1252 /usr/sbin/tinyproxy
               |-1253 /usr/sbin/tinyproxy
               |-1255 /usr/sbin/tinyproxy
               |-1256 /usr/sbin/tinyproxy
               |-1257 /usr/sbin/tinyproxy
               |-1258 /usr/sbin/tinyproxy
               |-1262 /usr/sbin/tinyproxy
               |-1263 /usr/sbin/tinyproxy
               |-1264 /usr/sbin/tinyproxy
               |-1265 /usr/sbin/tinyproxy
               `-1266 /usr/sbin/tinyproxy
proxy02:
    * tinyproxy.service - Tinyproxy lightweight HTTP Proxy
       Loaded: loaded (/lib/systemd/system/tinyproxy.service; enabled; vendor preset: enabled)
       Active: active (running) since Mon 2018-11-05 08:12:11 CET; 5 days ago
         Docs: man:tinyproxy(8)
               man:tinyproxy.conf(5)
      Process: 1093 ExecStart=/usr/sbin/tinyproxy (code=exited, status=0/SUCCESS)
     Main PID: 1164 (tinyproxy)
        Tasks: 21 (limit: 2299)
       CGroup: /system.slice/tinyproxy.service
               |-1164 /usr/sbin/tinyproxy
               |-1250 /usr/sbin/tinyproxy
               |-1251 /usr/sbin/tinyproxy
               |-1253 /usr/sbin/tinyproxy
               |-1254 /usr/sbin/tinyproxy
               |-1255 /usr/sbin/tinyproxy
               |-1256 /usr/sbin/tinyproxy
               |-1257 /usr/sbin/tinyproxy
               |-1258 /usr/sbin/tinyproxy
               |-1259 /usr/sbin/tinyproxy
               |-1261 /usr/sbin/tinyproxy
               |-1263 /usr/sbin/tinyproxy
               |-1265 /usr/sbin/tinyproxy
               |-1266 /usr/sbin/tinyproxy
               |-1268 /usr/sbin/tinyproxy
               |-1269 /usr/sbin/tinyproxy
               |-1271 /usr/sbin/tinyproxy
               |-1272 /usr/sbin/tinyproxy
               |-1273 /usr/sbin/tinyproxy
               |-1275 /usr/sbin/tinyproxy
               `-1276 /usr/sbin/tinyproxy
```

Check if Kubelet is running.

```bash
salt -G role:proxy cmd.run 'systemctl --lines 0 status kubelet'
```

```text
proxy01:
    * kubelet.service - Kubernetes Kubelet
       Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
      Drop-In: /etc/systemd/system/kubelet.service.d
               `-0-containerd.conf
       Active: active (running) since Wed 2018-11-07 10:17:40 CET; 3 days ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet
     Main PID: 1597 (kubelet)
        Tasks: 16 (limit: 2299)
       CGroup: /system.slice/kubelet.service
               `-1597 /usr/local/bin/kubelet --allow-privileged=true --config=/var/lib/kubelet/kubelet-config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --hostname-override=proxy01 --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --network-plugin=cni --node-labels=kubernetes.io/role=node,beta.kubernetes.io/fluentd-ds-ready=true,node-role.kubernetes.io/ingress=true --volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --register-with-taints=node-role.kubernetes.io/ingress=:NoSchedule --v=2
proxy02:
    * kubelet.service - Kubernetes Kubelet
       Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
      Drop-In: /etc/systemd/system/kubelet.service.d
               `-0-containerd.conf
       Active: active (running) since Mon 2018-11-05 08:12:22 CET; 5 days ago
         Docs: https://github.com/kubernetes/kubernetes
               https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet
     Main PID: 1509 (kubelet)
        Tasks: 18 (limit: 2299)
       CGroup: /system.slice/kubelet.service
               `-1509 /usr/local/bin/kubelet --allow-privileged=true --config=/var/lib/kubelet/kubelet-config.yaml --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --hostname-override=proxy02 --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --network-plugin=cni --node-labels=kubernetes.io/role=node,beta.kubernetes.io/fluentd-ds-ready=true,node-role.kubernetes.io/ingress=true --volume-plugin-dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec --register-with-taints=node-role.kubernetes.io/ingress=:NoSchedule --v=2
```