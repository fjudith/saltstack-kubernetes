proxyinjector-demo-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/proxyinjector/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: proxyinjector-namespace
    - watch:
      - file:  /srv/kubernetes/manifests/proxyinjector/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/proxyinjector/ingress.yaml