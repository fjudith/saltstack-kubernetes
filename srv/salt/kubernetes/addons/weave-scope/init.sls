{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/weave-scope:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/weave-scope/cluster-role-binding.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/files/cluster-role-binding.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/cluster-role.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/files/cluster-role.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/deploy.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/templates/deploy.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/ds.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/templates/ds.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/ns.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/files/ns.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/probe-deploy.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/templates/probe-deploy.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/psp.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/files/psp.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/sa.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/files/sa.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/svc.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/files/svc.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/weave-scope/ingress.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://kubernetes/addons/weave-scope/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-weave-scope-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/weave-scope/deploy.yaml
      - file: /srv/kubernetes/manifests/weave-scope/ds.yaml
      - file: /srv/kubernetes/manifests/weave-scope/probe-deploy.yaml
      - file: /srv/kubernetes/manifests/weave-scope/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/ns.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/sa.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/cluster-role.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/cluster-role-binding.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/deploy.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/ds.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/probe-deploy.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/svc.yaml
        kubectl apply -f /srv/kubernetes/manifests/weave-scope/ingress.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'