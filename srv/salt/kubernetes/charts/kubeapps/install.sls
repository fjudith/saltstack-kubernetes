kubeapps:
  cmd.run:
    - watch:
      - cmd: kubeapps-fetch-charts
      - cmd: kubeapps-namespace
      - file: /srv/kubernetes/manifests/kubeapps/values.yaml
    - runas: root
    - cwd: /srv/kubernetes/manifests/kubeapps/kubeapps
    - name: |
        kubectl apply -f crds/
        helm upgrade --install kubeapps --namespace kubeapps \
            --values /srv/kubernetes/manifests/kubeapps/values.yaml \
            "./" --wait --timeout 3m