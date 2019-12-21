concourse-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - name: /srv/kubernetes/manifests/concourse/namespace.yaml
    - source: salt://kubernetes/charts/concourse/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/concourse/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/concourse/namespace.yaml