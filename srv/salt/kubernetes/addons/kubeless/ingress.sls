kubeless-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/kubeless/ingress.yaml
    - source: salt://kubernetes/addons/kubeless/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/kubeless
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/kubeless/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'