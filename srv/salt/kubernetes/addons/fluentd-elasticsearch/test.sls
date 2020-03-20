query-kibana:
  http.wait_for_successful_query:
    - watch:
      - cmd: fluentd-elasticsearch
    - name: http://localhost:8080/api/v1/namespaces/kube-system/services/kibana-logging/proxy
    - wait_for: 300
    - request_interval: 5
    - status: 200

query-elasticsearch:
  http.wait_for_successful_query:
    - watch:
      - cmd: fluentd-elasticsearch
    - name: http://localhost:8080/api/v1/namespaces/kube-system/services/elasticsearch-logging/proxy
    - wait_for: 300
    - request_interval: 5
    - status: 200