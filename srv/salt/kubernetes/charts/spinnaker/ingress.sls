spinnaker-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: spinnaker-namespace
    - watch:
      - file:  /srv/kubernetes/manifests/spinnaker/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/spinnaker/ingress.yaml
