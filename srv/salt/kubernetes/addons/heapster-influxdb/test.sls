query-heapster:
  http.wait_for_successful_query:
    - watch:
      - cmd: heapster-influxdb-grafana
    - name: http://localhost:8080/api/v1/namespaces/kube-system/services/heapster/proxy
    - wait_for: 120
    - request_interval: 5
    - status: 503

query-influxdb:
  http.wait_for_successful_query:
    - watch:
      - cmd: heapster-influxdb-grafana
    - name: http://localhost:8080/api/v1/namespaces/kube-system/services/monitoring-influxdb:http/proxy
    - wait_for: 120
    - request_interval: 5
    - status: 503

query-grafana:
  http.wait_for_successful_query:
    - watch:
      - cmd: heapster-influxdb-grafana
    - name: http://localhost:8080/api/v1/namespaces/kube-system/services/monitoring-grafana/proxy
    - wait_for: 120
    - request_interval: 5
    - status: 200