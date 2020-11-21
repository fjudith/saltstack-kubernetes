gitea-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/gitea/gitea

gitea-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: gitea-remove-charts
      - file: /srv/kubernetes/manifests/gitea
    - cwd: /srv/kubernetes/manifests/gitea
    - name: |
        helm repo add gitea https://dl.gitea.io/charts/
        helm fetch --untar gitea/gitea