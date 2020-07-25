hydra-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/hydra

hydra-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: hydra-remove-charts
      - file: /srv/kubernetes/manifests/ory
    - cwd: /srv/kubernetes/manifests/ory
    - name: |
        helm repo add ory https://k8s.ory.sh/helm/charts
        helm fetch --untar ory/hydra