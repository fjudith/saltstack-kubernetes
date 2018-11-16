{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/weave-scope:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/weave-scope/scope.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/templates/scope.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/ingress.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-weave-scope-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/weave-scope/scope.yaml
      - file: /srv/kubernetes/manifests/weave-scope/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/scope.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'