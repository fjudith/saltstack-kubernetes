gitea-ingress:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/gitea
    - name: /srv/kubernetes/manifests/gitea/gitea-ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: gitea
    - watch:
      - file: /srv/kubernetes/manifests/gitea/gitea-ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/gitea/gitea-ingress.yaml
