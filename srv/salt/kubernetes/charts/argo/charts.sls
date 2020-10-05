argo-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/argo/argo

argo-events-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/argo/argo-events

argo-cd-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/argo/argo-cd

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

argo-events-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: argo-events-remove-charts
      - file: /srv/kubernetes/manifests/argo
      - cmd: argo-fetch-charts
    - cwd: /srv/kubernetes/manifests/argo
    - name: |
        helm fetch --untar argo/argo-events
      
argo-cd-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: argo-cd-remove-charts
      - file: /srv/kubernetes/manifests/argo
      - cmd: argo-fetch-charts
    - cwd: /srv/kubernetes/manifests/argo
    - name: |
        helm fetch --untar argo/argo-cd