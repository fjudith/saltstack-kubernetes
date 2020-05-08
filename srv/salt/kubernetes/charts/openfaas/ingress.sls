openfaas-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/openfaas/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openfaas/ingress.yaml
      - cmd: openfaas-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/openfaas/ingress.yaml
