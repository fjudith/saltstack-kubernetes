heapster-influxdb-grafana:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/heapster-influxdb/heapster-controller.yaml
      - /srv/kubernetes/manifests/heapster-influxdb/heapster-rbac.yaml
      - /srv/kubernetes/manifests/heapster-influxdb/heapster-service.yaml
      - /srv/kubernetes/manifests/heapster-influxdb/influxdb-grafana.yaml
      - /srv/kubernetes/manifests/heapster-influxdb/influxdb-service.yaml
      - /srv/kubernetes/manifests/heapster-influxdb/grafana-service.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/heapster-influxdb/heapster-controller.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-influxdb/heapster-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-influxdb/heapster-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-influxdb/influxdb-grafana.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-influxdb/influxdb-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-influxdb/grafana-service.yaml