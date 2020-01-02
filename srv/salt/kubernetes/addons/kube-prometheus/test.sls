query-kube-prometheus-required-api:
  http.wait_for_successful_query:
    - watch:
      - cmd: kube-prometheus
    - name: 'http://127.0.0.1:8080/apis/monitoring.coreos.com'
    - match: monitoring.coreos.com
    - wait_for: 180
    - request_interval: 5
    - status: 200