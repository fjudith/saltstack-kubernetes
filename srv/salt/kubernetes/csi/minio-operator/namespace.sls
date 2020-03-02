minio-operator-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - name: /srv/kubernetes/manifests/minio-operator/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/minio-operator/namespace.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'