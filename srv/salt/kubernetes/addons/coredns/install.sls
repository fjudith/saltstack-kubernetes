kubernetes-coredns-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/coredns.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/coredns.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'