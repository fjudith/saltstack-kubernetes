{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/helm:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/tmp/helm-v{{ common.addons.helm.version }}:
  archive.extracted:
    - source: https://get.helm.sh/helm-v{{ common.addons.helm.version }}-linux-amd64.tar.gz
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
    - name: | 
        helm repo add stable https://kubernetes-charts.storage.googleapis.com/
        /usr/local/bin/helm repo update
    - require:
      - file: /usr/local/bin/helm