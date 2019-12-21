{%- from "kubernetes/map.jinja" import charts with context -%}

spinnaker:
  cmd.run:
    - runas: root
    - only_if: kubectl get storageclass | grep \(default\)
    - cwd: /srv/kubernetes/manifests/spinnaker/spinnaker
    - require:
      - cmd: spinnaker-namespace
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/values.yaml
      - file: /srv/kubernetes/manifests/spinnaker/spinnaker/requirements.yaml
      - file: /srv/kubernetes/manifests/spinnaker/spinnaker/requirements.lock
      - file: /srv/kubernetes/manifests/spinnaker/spinnaker/Charts.yaml
      - cmd: spinnaker-fetch-charts
    - name: |
        helm dependency update && \
        helm upgrade --install spinnaker --namespace spinnaker \
          --set halyard.spinnakerVersion={{ charts.spinnaker.version }} \
          --set halyard.image.tag={{ charts.spinnaker.halyard_version }} \
          --values /srv/kubernetes/manifests/spinnaker/values.yaml \
          "./" --timeout 10m