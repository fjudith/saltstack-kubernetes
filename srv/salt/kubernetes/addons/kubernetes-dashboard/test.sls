kubernetes-dashboard-wait:
  cmd.run:
    - require:
      - cmd: kubernetes-dashboard
    - runas: root
    - name: |
        until kubectl -n kubernetes-dashboard get pods --field-selector=status.phase=Running --selector=k8s-app=kubernetes-dashboard; do printf 'kubernetes-dashboard is not Running' && sleep 5; done
        until kubectl -n kubernetes-dashboard get pods --field-selector=status.phase=Running --selector=k8s-app=dashboard-metrics-scraper; do printf 'dashboard-metrics-scraper is not Running' && sleep 5; done
    - use_vt: True
    - timeout: 180

query-kubernetes-dashboard:
  http.wait_for_successful_query:
    - watch:
      - cmd: kubernetes-dashboard
    - name: http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:443/proxy
    - wait_for: 120
    - request_interval: 5
    - status: 200