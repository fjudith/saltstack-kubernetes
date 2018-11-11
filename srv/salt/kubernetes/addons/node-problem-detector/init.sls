{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/npd.yaml:
    file.managed:
    - source: salt://kubernetes/addons/node-problem-detector/templates/npd.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-npd-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/npd.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/npd.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
