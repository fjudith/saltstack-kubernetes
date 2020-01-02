kube-prometheus-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/ingress.yaml
    - source: salt://kubernetes/addons/kube-prometheus/templates/ingress.yaml.j2
    - require:
      - git: kube-prometheus-repo
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - require:
      - cmd: kube-prometheus-namespace
    - watch:
      - file:  /srv/kubernetes/manifests/kube-prometheus/ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/ingress.yaml
