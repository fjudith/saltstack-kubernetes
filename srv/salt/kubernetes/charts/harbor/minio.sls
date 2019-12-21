harbor-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/object-store.yaml
    - source: salt://kubernetes/charts/harbor/templates/object-store.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/harbor/object-store.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/harbor/object-store.yaml