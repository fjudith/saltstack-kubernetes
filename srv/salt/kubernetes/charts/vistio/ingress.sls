vistio-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/vistio-ingress.yaml
    - source: salt://kubernetes/charts/vistio/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
      - require:
        - cmd: vistio
      - watch:
        - file: /srv/kubernetes/manifests/vistio-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/vistio-ingress.yaml
