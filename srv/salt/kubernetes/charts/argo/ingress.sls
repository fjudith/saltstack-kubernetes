argo-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/argo-ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/argo-ingress.yaml
      - cmd: argo-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/argo-ingress.yaml
