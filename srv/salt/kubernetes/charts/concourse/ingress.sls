concourse-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/concourse-ingress.yaml
    - source: salt://kubernetes/charts/concourse/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/concourse-ingress.yaml
      - cmd: concourse-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/concourse-ingress.yaml
