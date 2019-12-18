proxyinjector-demo-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/proxyinjector/ingress.yaml
    - source: salt://kubernetes/charts/proxyinjector/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: proxyinjector-namespace
    - watch:
      - file:  /srv/kubernetes/manifests/proxyinjector/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/proxyinjector/ingress.yaml