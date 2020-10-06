
argo-cd-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/argo-cd/argo-cd

argo-cd-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: argo-cd-remove-charts
      - file: /srv/kubernetes/manifests/argo-cd
    - cwd: /srv/kubernetes/manifests/argo-cd
    - name: |
        helm repo add argo https://argoproj.github.io/argo-helm
        helm fetch --untar argo/argo-cd