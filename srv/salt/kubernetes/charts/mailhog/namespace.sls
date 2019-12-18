mailhog-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mailhog
    - name: /srv/kubernetes/manifests/mailhog/namespace.yaml
    - source: salt://kubernetes/charts/mailhog/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/mailhog/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mailhog/namespace.yaml