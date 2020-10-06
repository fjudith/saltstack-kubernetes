argo-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/argo/argo

argo-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: argo-remove-charts
      - file: /srv/kubernetes/manifests/argo
    - cwd: /srv/kubernetes/manifests/argo
    - name: |
        helm repo add argo https://argoproj.github.io/argo-helm
        helm fetch --untar argo/argo