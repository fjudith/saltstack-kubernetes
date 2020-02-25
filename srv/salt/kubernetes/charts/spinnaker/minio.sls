spinnaker-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - name: /srv/kubernetes/manifests/spinnaker/minioinstance.yaml
    - source: salt://{{ tpldir }}/templates/minioinstance.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/minioinstance.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/spinnaker/minioinstance.yaml