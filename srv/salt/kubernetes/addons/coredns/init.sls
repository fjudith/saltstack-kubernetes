{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/coredns.yaml:
    file.managed:
    - source: salt://kubernetes/addons/coredns/coredns.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-coredns-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/coredns.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/coredns.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'