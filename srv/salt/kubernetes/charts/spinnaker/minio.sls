spinnaker-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - name: /srv/kubernetes/manifests/spinnaker/object-store.yaml
    - source: salt://kubernetes/charts/spinnaker/templates/object-store.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/object-store.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/spinnaker/object-store.yaml