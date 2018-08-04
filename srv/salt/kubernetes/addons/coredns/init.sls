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
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/coredns.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/coredns.yaml