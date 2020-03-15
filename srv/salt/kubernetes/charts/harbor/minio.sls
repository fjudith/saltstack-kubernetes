harbor-minio:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/minioinstance.yaml
    - source: salt://{{ tpldir }}/templates/minioinstance.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/harbor/minioinstance.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/harbor/minioinstance.yaml