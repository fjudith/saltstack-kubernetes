nuclio:
  cmd.run:
    - runas: root
    - require:
      - cmd: nuclio-namespace
    - watch:
      - file: /srv/kubernetes/manifests/nuclio/values.yaml
      - cmd: nuclio-fetch-charts
    - cwd: /srv/kubernetes/manifests/nuclio/nuclio
    - name: |
        helm upgrade --install nuclio --namespace nuclio \
          --values /srv/kubernetes/manifests/nuclio/values.yaml \
          "./" --wait --timeout 5m