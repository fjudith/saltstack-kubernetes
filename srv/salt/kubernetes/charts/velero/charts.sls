velero-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/velero/velero

velero-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: velero-remove-charts
      - file: /srv/kubernetes/manifests/velero
    - cwd: /srv/kubernetes/manifests/velero
    - name: |
        helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
        helm fetch --untar vmware-tanzu/velero