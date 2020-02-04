concourse-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - name: /srv/kubernetes/manifests/concourse/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/concourse/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/concourse/namespace.yaml