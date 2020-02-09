kube-prometheus-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - git: kube-prometheus-repo
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: kube-prometheus-namespace
    - watch:
      - file:  /srv/kubernetes/manifests/kube-prometheus/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/ingress.yaml
