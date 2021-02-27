minio-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/minio-operator/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/minio-operator
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/minio-operator/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/minio-operator/ingress.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose