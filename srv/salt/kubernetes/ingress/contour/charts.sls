contour-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/contour/ingress-contour

contour-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/contour
      - file: contour-remove-charts
    - cwd: /srv/kubernetes/manifests/contour
    - name: |
        helm repo add bitnami https://charts.bitnami.com/bitnami
        helm fetch --untar bitnami/contour
