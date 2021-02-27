minio-operator-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - name: /srv/kubernetes/manifests/minio-operator/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/minio-operator/namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/namespace.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose