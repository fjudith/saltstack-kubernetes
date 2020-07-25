hydra-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/hydra-ingress.yaml
    - source: salt://{{ tpldir }}/templates/hydra-ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/hydra-ingress.yaml
      - cmd: ory-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/hydra-ingress.yaml
