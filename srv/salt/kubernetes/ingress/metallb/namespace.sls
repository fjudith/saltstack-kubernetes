metallb-namespace:
  file.managed:
    - name: /srv/kubernetes/manifests/metallb/namespace.yaml
    - source: salt://kubernetes/ingress/metallb/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/metallb
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/metallb/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/metallb/namespace.yaml
