metrics-server:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/metrics-server/metrics-server-deployment.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/metrics-server/metrics-server-deployment.yaml