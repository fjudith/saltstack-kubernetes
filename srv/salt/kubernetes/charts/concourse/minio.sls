concourse-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - name: /srv/kubernetes/manifests/concourse/object-store.yaml
    - source: salt://kubernetes/charts/concourse/templates/object-store.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/concourse/object-store.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/concourse/object-store.yaml