rook-cockroachdb-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/rook-cockroachdb
    - name: /srv/kubernetes/manifests/rook-cockroachdb/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/rook-cockroachdb/namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-cockroachdb/namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'