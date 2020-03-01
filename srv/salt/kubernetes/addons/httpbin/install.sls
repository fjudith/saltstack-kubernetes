httpbin:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/httpbin/deployment.yaml
      - file: /srv/kubernetes/manifests/httpbin/service.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/httpbin/deployment.yaml
        kubectl apply -f /srv/kubernetes/manifests/httpbin/service.yaml