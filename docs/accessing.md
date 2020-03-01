# Accessing

Once created using [terraform](https://terraform.io) and [saltstack](https://salstack.com) procedures. the cluster can be accessed by the following URLs.

## External

> **Replace** example.com" with the "public-domain" value from the salt pillar.

Usage | Product | Url
----- | ------- | ---
Cluster monitoring | **Grafana** | https://grafana.example.com
Cluster management | **Prometheus** | https://prometheus.example.com
Cluster altert management | **AltertManager** | https://altermanager.example.com
Rook-Ceph Storage monitoring | **Ceph UI** | https://ceph.example.com
Minio Storage management | **Minio UI** | https://minio.example.com
Network Monitoring | **Weave Scope** | https://scope.example.com
Container Image Registry | **Harbor** | https://registry.example.com
Istio Metrics | **Grafana** | https://istio-grafana.example.com
Istio Tracing | **Jaeger** | https://istio-tracing.example.com
Istio Servicegraph | **Servicegraph** | https://istio-servicegraph/force/forcegraph.html


## Internal

An access Token is required to access the Kubernetes API. It can be retreive in the salt pillar (i.e /srv/pillar/cluster_config.sls).


Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-curl).
Download the Kubernetes cluster CA certificate.

```bash
export CLUSTER_DOMAIN="example.com"

mkdir -p ~/.kube/ssl/${CLUSTER_DOMAIN}
scp root@proxy01.${CLUSTER_DOMAIN}:/etc/kubernetes/ssl/ca.pem ~/.kube/ssl/${CLUSTER_DOMAIN}/
```

Create the kubectl configuration file.

```bash
export CLUSTER_TOKEN=mykubernetestoken
export CLUSTER_NAME="example"
export KUBECONFIG="~/.kube/config"

kubectl config set-cluster ${CLUSTER_NAME} \
--server=https://kubernetes.${CLUSTER_DOMAIN}:6443 \
--certificate-authority=~/.kube/ssl/${CLUSTER_DOMAIN}/ca.pem

kubectl config set-credentials admin-${CLUSTER_NAME} \
--token=${CLUSTER_TOKEN}

kubectl config set-context ${CLUSTER_NAME} \
--cluster=${CLUSTER_NAME} \
--user=admin-${CLUSTER_NAME}

kubectl config use-context ${CLUSTER_NAME}
```

### Validate the access.

Check the Kubernetes cluster component health.

```bash
kubectl get componentstatus

NAME                 STATUS    MESSAGE              ERROR
etcd-2               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health": "true"}
```

Check the Kubernetes cluster nodes status.

```bash
kubectl get nodes

NAME       STATUS   ROLES          AGE   VERSION
master01   Ready    master         11d   v1.12.1
master02   Ready    master         11d   v1.12.1
master03   Ready    master         11d   v1.12.1
node01     Ready    node           11d   v1.12.1
node02     Ready    node           11d   v1.12.1
node03     Ready    node           11d   v1.12.1
node04     Ready    node           11d   v1.12.1
node05     Ready    node           11d   v1.12.1
node06     Ready    node           11d   v1.12.1
proxy01    Ready    ingress,node   11d   v1.12.1
proxy02    Ready    ingress,node   11d   v1.12.1
```

Retreive the URLs protected by the Kube-APIserver.

```bash
kubectl cluster-info

Kubernetes master is running at https://kubernetes.example.com:6443
Elasticsearch is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/elasticsearch-logging/proxy
Heapster is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/heapster/proxy
Kibana is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/kibana-logging/proxy
CoreDNS is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
kubernetes-dashboard is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
Grafana is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy
InfluxDB is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/monitoring-influxdb:http/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

## Kubectl Proxy

The URLs returned by `kubectl cluster-info` are protected by a mutual TLS authentification. Meaning that direct access from your Web Browser is denied until you register the appropriate certificate and private key in it.

Prefer the `kubectl proxy` command which enables the access to URL protected by the Kube-APIServer.
Once launched. URLs are available from the **localhost** on the HTTP port 8001.

> e.g. http://localhost:8001/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

![Kubernetes Dashboard](./media/kubernetes_dashboard.png)