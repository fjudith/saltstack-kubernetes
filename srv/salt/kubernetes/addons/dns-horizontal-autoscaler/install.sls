dns-horizontal-autoscaler-rbac:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/dha-rbac.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/dha-rbac.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

dns-horizontal-autoscaler-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/dha-deployment.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/dha-deployment.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'