spinnaker-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/spinnaker/spinnaker

spinnaker-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: spinnaker-remove-charts
      - file: /srv/kubernetes/manifests/spinnaker
    - cwd: /srv/kubernetes/manifests/spinnaker
    - name: |
        helm fetch --untar stable/spinnaker
  file.absent:
    - name: /srv/kubernetes/manifests/spinnaker/spinnaker/charts

/srv/kubernetes/manifests/spinnaker/spinnaker/requirements.yaml:
  file.managed:
    - watch:
      - cmd: spinnaker-fetch-charts
    - source: salt://kubernetes/charts/spinnaker/tmp/requirements.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/spinnaker/spinnaker/requirements.lock:
  file.managed:
    - watch:
      - cmd: spinnaker-fetch-charts
    - source: salt://kubernetes/charts/spinnaker/tmp/requirements.lock
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/spinnaker/spinnaker/Charts.yaml:
  file.managed:
    - watch:
      - cmd: spinnaker-fetch-charts
    - source: salt://kubernetes/charts/spinnaker/tmp/Charts.yaml
    - user: root
    - group: root
    - mode: 644