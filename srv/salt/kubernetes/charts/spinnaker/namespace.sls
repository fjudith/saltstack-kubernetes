spinnaker-namespace:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/spinnaker/namespace.yaml
