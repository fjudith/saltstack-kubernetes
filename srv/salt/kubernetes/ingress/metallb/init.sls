{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/metallb:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/metallb/values.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/metallb
    - source: salt://kubernetes/ingress/metallb/files/values.yaml
    - user: root
    - group: root
    - mode: 644

kubernetes-nginx-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/metallb/values.yaml
    - name: |
        helm upgrade --install \
          metallb \
          --namespace metallb-system \
          --values /srv/kubernetes/manifests/metallb/values.yaml \
          stable/metallb
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'