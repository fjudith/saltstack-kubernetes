argo-cd-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/cd-ingress.yaml
    - source: salt://{{ tpldir }}/templates/cd-ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/cd-ingress.yaml
      - cmd: argo-cd-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/cd-ingress.yaml
