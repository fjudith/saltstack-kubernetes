# Prometheus Query

sum by (container_name) (rate(container_cpu_usage_seconds_total{namespace!="kube-system" or container_name!=""}[1m]))