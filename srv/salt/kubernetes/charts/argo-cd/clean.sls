argo-cd-teardown:
  cmd.run:
    - runas: root
    - name: |
        helm delete -n argocd argo-cd
        kubectl delete -f /srv/kubernetes/manifests/argo-cd-ingress.yaml
        kubectl delete -f /srv/kubernetes/manifests/argo-cd/argo-cd/crds/
        kubectl delete -f /srv/kubernetes/manifests/argo-cd/namespace.yaml