hydra-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/hydra

idp-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/example-idp

kratos-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/kratos

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

idp-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: idp-remove-charts
      - file: /srv/kubernetes/manifests/ory
      - cmd: hydra-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory
    - name: |
        helm fetch --untar ory/example-idp

kratos-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: kratos-remove-charts
      - file: /srv/kubernetes/manifests/ory
      - cmd: hydra-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory
    - name: |
        helm fetch --untar ory/kratos