istio-ingress:
  file.managed:
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - name: /srv/kubernetes/manifests/istio/ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/istio/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/istio/ingress.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose