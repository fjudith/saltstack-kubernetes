---
mayastor-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
    - name: /srv/kubernetes/manifests/mayastor/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/mayastor/namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/namespace.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
