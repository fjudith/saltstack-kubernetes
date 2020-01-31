openfaas-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - cwd: /srv/kubernetes/manifests/openfaas
    - name: |
        helm repo add openfaas https://openfaas.github.io/faas-netes/
        helm fetch --untar openfaas/openfaas

openfaas-cron-connector-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: /srv/kubernetes/manifests/openfaas
      - cmd: openfaas-fetch-charts
    - cwd: /srv/kubernetes/manifests/openfaas
    - name: |
        helm fetch --untar openfaas/cron-connector