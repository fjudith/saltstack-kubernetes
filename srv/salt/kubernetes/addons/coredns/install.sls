kubernetes-coredns-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/coredns.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/coredns.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose