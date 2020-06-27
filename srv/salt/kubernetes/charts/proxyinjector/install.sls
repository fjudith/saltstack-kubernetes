proxyinjector:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/proxyinjector/values.yaml
    - cwd: /srv/kubernetes/manifests/proxyinjector/helm/deployments/kubernetes/chart/proxyinjector
    - runas: root
    - name: |
        helm upgrade --install proxyinjector \
          --namespace default \
          --values /srv/kubernetes/manifests/proxyinjector/values.yaml \
          ./ --wait --timeout 3m