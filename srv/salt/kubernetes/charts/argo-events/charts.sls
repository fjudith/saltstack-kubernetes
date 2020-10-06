argo-events-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/argo-events/argo-events

argo-events-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: argo-events-remove-charts
      - file: /srv/kubernetes/manifests/argo-events
    - cwd: /srv/kubernetes/manifests/argo-events
    - name: |
        helm repo add argo https://argoproj.github.io/argo-helm
        helm fetch --untar argo/argo-events