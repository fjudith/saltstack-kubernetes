kubeapps-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/kubeapps/kubeapps

kubeapps-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: kubeapps-remove-charts
      - file: /srv/kubernetes/manifests/kubeapps
    - cwd: /srv/kubernetes/manifests/kubeapps
    - name: |
        helm repo add bitnami https://charts.bitnami.com/bitnami
        helm fetch --untar bitnami/kubeapps