mailhog-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/mailhog
    - cwd: /srv/kubernetes/manifests/mailhog
    - name: |
        helm repo add codecentric https://codecentric.github.io/helm-charts
        helm fetch --untar codecentric/mailhog