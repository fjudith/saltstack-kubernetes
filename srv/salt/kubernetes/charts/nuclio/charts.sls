nuclio-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/nuclio/nuclio

nuclio-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: nuclio-remove-charts
      - file: /srv/kubernetes/manifests/nuclio
    - cwd: /srv/kubernetes/manifests/nuclio
    - name: |
        helm repo add nuclio https://nuclio.github.io/nuclio/charts
        helm
        helm fetch --untar nuclio/nuclio