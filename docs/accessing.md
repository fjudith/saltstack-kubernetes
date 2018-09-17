# Accessing

Once created using [terraform]() and [saltstack]() procedures. the cluster can be accessed by the following URLs.

## External

> Replace "example.com" with the "public-domain" value from the salt pillar.

Usage | Product | Url
----- | ------- | ---
Cluster monitoring | **Grafana** | https://grafana.example.com
Cluster management | **Prometheus** | https://prometheus.example.com
Cluster altert management | **AltertManager** | https://altermanager.example.com
Storage Monitoring | **Ceph UI** | https://ceph.example.com
Network Monitoring | **Weave Scope** | https://scope.example.com

## Internal

Install Kubectl ()