vistio-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/vistio-ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
      - require:
        - cmd: vistio
      - watch:
        - file: /srv/kubernetes/manifests/vistio-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/vistio-ingress.yaml
