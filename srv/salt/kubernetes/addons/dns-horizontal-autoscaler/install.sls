dns-horizontal-autoscaler-rbac:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/dha-rbac.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/dha-rbac.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

dns-horizontal-autoscaler-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/dha-deployment.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/dha-deployment.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose