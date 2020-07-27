hydra-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/hydra

idp-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/example-idp

kratos-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/kratos

cockroachdb-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/cockroachdb

oathkeeper-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/ory/oathkeeper

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

/srv/kubernetes/manifests/ory/kratos/templates/configmap-config.yaml:
  file.managed:
    - watch:
      - cmd: kratos-fetch-charts
    - source: salt://{{ tpldir }}/patch/kratos-configmap.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

oathkeeper-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: oathkeeper-remove-charts
      - file: /srv/kubernetes/manifests/ory
      - cmd: hydra-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory
    - name: |
        helm fetch --untar ory/oathkeeper

cockroachdb-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: cockroachdb-remove-charts
      - file: /srv/kubernetes/manifests/ory
      - cmd: hydra-fetch-charts
    - cwd: /srv/kubernetes/manifests/ory
    - name: |
        helm repo add cockroachdb https://charts.cockroachdb.com
        helm fetch --untar cockroachdb/cockroachdb