kube-scan-ingress:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-scan/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - require:
      - file: /srv/kubernetes/manifests/kube-scan
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kube-scan/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-scan/ingress.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose