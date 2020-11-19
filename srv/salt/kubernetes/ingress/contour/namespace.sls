contour-namespace:
  file.managed:
    - name: /srv/kubernetes/manifests/contour/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/contour
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/contour/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/contour/namespace.yaml