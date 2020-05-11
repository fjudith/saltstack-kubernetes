nuclio-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/nuclio/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/nuclio/ingress.yaml
      - cmd: nuclio-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/nuclio/ingress.yaml
