velero-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/velero-ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/velero-ingress.yaml
      - cmd: velero-namespace
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/velero-ingress.yaml
