httpbin-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/httpbin/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/httpbin
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file:  /srv/kubernetes/manifests/httpbin/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/httpbin/ingress.yaml
