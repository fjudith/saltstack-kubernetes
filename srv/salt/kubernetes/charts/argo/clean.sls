argo-teardown:
  cmd.run:
    - runas: root
    - name: |
        helm delete -n argo argo
        kubectl delete -f /srv/kubernetes/manifests/argo-ingress.yaml
        kubectl delete -f /srv/kubernetes/manifests/argo/argo/crds/
        kubectl delete -f /srv/kubernetes/manifests/argo/namespace.yaml