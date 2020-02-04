concourse-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - name: /srv/kubernetes/manifests/concourse/minioinstance.yaml
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
      - file: /srv/kubernetes/manifests/concourse/minioinstance.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/concourse/minioinstance.yaml