minio-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/minio-operator/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/minio-operator/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'