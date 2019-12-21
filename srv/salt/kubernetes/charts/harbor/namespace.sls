harbor-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/namespace.yaml
    - source: salt://kubernetes/charts/harbor/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/harbor/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/harbor/namespace.yaml
