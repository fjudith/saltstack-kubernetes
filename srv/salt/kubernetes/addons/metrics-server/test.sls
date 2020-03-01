query-metrics-server:
  http.wait_for_successful_query:
    - watch:
      - cmd: metrics-server
    - name: http://localhost:8080/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
    - wait_for: 120
    - request_interval: 5
    - status: 403