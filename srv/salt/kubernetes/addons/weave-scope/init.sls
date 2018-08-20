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
    - source: salt://kubernetes/addons/weave-scope/scope.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-weave-scope-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/weave-scope/scope.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/scope.yaml