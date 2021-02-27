rook-edgefs-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/rook-edgefs/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/rook-edgefs
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/rook-edgefs/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/rook-edgefs/ingress.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose