metallb:
  cmd.run:
    - runas: root
    - watch:
      - cmd: metallb-namespace
      - cmd: metallb-fetch-charts
    - cwd: /srv/kubernetes/manifests/metallb/metallb
    - name: |
        helm upgrade --install metallb --namespace metallb-system \
            --values /srv/kubernetes/manifests/metallb/values.yaml \
            "./" --wait --timeout 5m