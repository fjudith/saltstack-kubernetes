spinnaker-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/spinnaker/ingress.yaml
    - source: salt://kubernetes/charts/spinnaker/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/spinnaker
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: spinnaker-namespace
    - watch:
      - file:  /srv/kubernetes/manifests/spinnaker/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/spinnaker/ingress.yaml

harbor-minio-ingress:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/harbor
    - name: /srv/kubernetes/manifests/harbor/ingress.yaml
    - source: salt://kubernetes/charts/harbor/templates/ingress.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: harbor
    - watch:
      - file: /srv/kubernetes/manifests/harbor/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/harbor/ingress.yaml
