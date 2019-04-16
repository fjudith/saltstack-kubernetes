{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/httpbin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/httpbin/deployment.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/httpbin
    - source: salt://kubernetes/addons/httpbin/files/deployment.yaml
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/srv/kubernetes/manifests/httpbin/service.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/httpbin
    - source: salt://kubernetes/addons/httpbin/files/service.yaml
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/srv/kubernetes/manifests/httpbin/ingress.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/httpbin
    - source: salt://kubernetes/addons/httpbin/templates/ingress.yaml.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja

httpbin-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/httpbin/deployment.yaml
      - file: /srv/kubernetes/manifests/httpbin/service.yaml
      - file: /srv/kubernetes/manifests/httpbin/ingress.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/httpbin/deployment.yaml
        kubectl apply -f /srv/kubernetes/manifests/httpbin/service.yaml
        kubectl apply -f /srv/kubernetes/manifests/httpbin/ingress.yaml