fission-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/fission
    - name: /srv/kubernetes/manifests/fission/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/fission/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/fission/namespace.yaml
