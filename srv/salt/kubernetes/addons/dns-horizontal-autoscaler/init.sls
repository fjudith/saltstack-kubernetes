{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml:
    file.managed:
    - source: salt://kubernetes/addons/dns-horizontal-autoscaler/dns-horizontal-autoscaler.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-dns-horizontal-autoscaler-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml
    - unless: curl --silent 'http://127.0.0.1:8080/version/'
