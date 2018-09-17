# InfluxDB Grafana


<img src="https://upload.wikimedia.org/wikipedia/commons/9/9d/Grafana_logo.png" alt="drawing" style="width:100px;"/>
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Influxdb_logo.svg/1200px-Influxdb_logo.svg.png" alt="drawing" style="width:300px;"/>

Infludb Grafana provides monitoring visualization of Heapster related metrics.
This service is exposted via the kube-apiserver proxy feature.

Use the following command line identify the URLs to access this solution

```bash
kubectl cluster-info
```

```text
...
Heapster is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/heapster/proxy
Grafana is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy
InfluxDB is running at https://kubernetes.example.com:6443/api/v1/namespaces/kube-system/services/monitoring-influxdb:http/proxy
```