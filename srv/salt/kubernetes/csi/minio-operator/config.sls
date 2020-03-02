/srv/kubernetes/manifests/minio-operator:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/minio-operator/minio-operator.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - source: salt://{{ tpldir }}/templates/minio-operator.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/minio-operator/minioinstance.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - source: salt://{{ tpldir }}/templates/minioinstance.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

