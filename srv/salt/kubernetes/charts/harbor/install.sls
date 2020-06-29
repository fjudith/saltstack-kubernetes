harbor:
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - watch:
        - cmd: harbor-namespace
        - cmd: harbor-fetch-charts
        - file: /srv/kubernetes/manifests/harbor/values.yaml
    - cwd: /srv/kubernetes/manifests/harbor/harbor
    - runas: root
    - name: |
        helm dependency update
        helm upgrade --install harbor \
          --namespace harbor \
          --values /srv/kubernetes/manifests/harbor/values.yaml \
          "./" --wait --timeout 10m