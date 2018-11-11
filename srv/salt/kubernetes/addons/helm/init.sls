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
    - source: salt://kubernetes/addons/helm/files/helm-rbac.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/helm/helm-tiller.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/templates/helm-tiller.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/helm/helm-serviceaccount.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/files/helm-serviceaccount.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

tiller:
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
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

/tmp/helm-v{{ common.addons.helm.version }}:
  archive.extracted:
    - source: https://storage.googleapis.com/kubernetes-helm/helm-v{{ common.addons.helm.version }}-linux-amd64.tar.gz
    - source_hash: {{ common.addons.helm.source_hash }}
    - user: root
    - group: root
    - archive_format: tar
    - enforce_toplevel: false

/usr/local/bin/helm:
  file.copy:
    - source: /tmp/helm-v{{ common.addons.helm.version }}/linux-amd64/helm
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - archive: /tmp/helm-v{{ common.addons.helm.version }}
    - unless: cmp -s /usr/local/bin/helm /tmp/helm-v{{ common.addons.helm.version }}/linux-amd64/helm

helm:
  cmd.run:
    - name: /usr/local/bin/helm init --client-only --home /srv/helm/home
    - unless: test -d /srv/helm/home
    - require:
      - file: /usr/local/bin/helm