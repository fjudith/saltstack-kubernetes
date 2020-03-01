metrics-server:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/metrics-server/aggregated-metrics-reader.yaml
      - file: /srv/kubernetes/manifests/metrics-server/auth-delegator.yaml
      - file: /srv/kubernetes/manifests/metrics-server/auth-reader.yaml
      - file: /srv/kubernetes/manifests/metrics-server/metrics-apiservice.yaml
      - file: /srv/kubernetes/manifests/metrics-server/metrics-server-deployment.yaml
      - file: /srv/kubernetes/manifests/metrics-server/metrics-server-service.yaml
      - file: /srv/kubernetes/manifests/metrics-server/resource-reader.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/metrics-server/