{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/helm:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/helm/helm-rbac.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/helm-rbac.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/helm/helm-tiller.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/helm-tiller.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/helm/helm-serviceaccount.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/helm-serviceaccount.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-helm-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/helm/helm-rbac.yaml
      - file: /srv/kubernetes/manifests/helm/helm-tiller.yaml
      - file: /srv/kubernetes/manifests/helm/helm-serviceaccount.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/helm/helm-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/helm/helm-tiller.yaml
        kubectl apply -f /srv/kubernetes/manifests/helm/helm-serviceaccount.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
