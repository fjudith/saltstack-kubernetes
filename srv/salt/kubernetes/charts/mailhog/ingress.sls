mailhog-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/mailhog/ingress.yaml
    - source: salt://kubernetes/charts/mailhog/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
      - watch:
        - file: /srv/kubernetes/manifests/mailhog/ingress.yaml
        - cmd: mailhog-namespace
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/mailhog/ingress.yaml
