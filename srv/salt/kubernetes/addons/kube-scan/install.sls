kube-scan:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kube-scan/deployment.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-scan/deployment.yaml