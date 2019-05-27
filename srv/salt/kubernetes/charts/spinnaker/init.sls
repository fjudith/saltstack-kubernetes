{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/kubernetes/manifests/spinnaker:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/spinnaker/values-minio.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/spinnaker
    - source: salt://kubernetes/charts/spinnaker/templates/values-minio.yaml.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja

{# /srv/kubernetes/manifests/spinnaker/InstallHalyard.sh:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/spinnaker
    - source: https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
    - user: root
    - group: root
    - mode: 755
    - skip_verify: true

hal:
  cmd.run:
    - runas: root
    - cwd: /srv/kubernetes/manifests/spinnaker
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/InstallHalyard.sh
    - name: |
        /srv/kubernetes/manifests/spinnaker/InstallHalyard.sh
    - user_vt: true #}

spinnaker-namespace:
  cmd.run:
    - unless: kubectl get namespace spinnaker
    - name: |
        kubectl create namespace spinnaker

spinnaker:
  cmd.run:
    - runas: root
    - only_if: kubectl get storageclass | grep \(default\)
    - env:
      - HELM_HOME: /srv/helm/home
    - require:
      - cmd: spinnaker-namespace
    - watch:
      - file: /srv/kubernetes/manifests/spinnaker/values-minio.yaml
    - name: |
        helm repo update
        helm upgrade --install spinnaker --namespace spinnaker \
          --set halyard.spinnakerVersion={{ charts.spinnaker.version }} \
          --set halyard.image.tag={{ charts.spinnaker.halyard_version }} \
          {%- if master.storage.get('rook_minio', {'enabled': False}).enabled %}
          --values /srv/kubernetes/manifests/spinnaker/values-minio.yaml \
          {%- else -%}
          --set minio.enabled=true \
          --set minio.persistence.enabled=true \
          {%- endif %}
          --set redis.enabled=true \
          --set redis.cluster.enabled=true \
          --set redis.master.persistence.enabled=true \
          "stable/spinnaker" --timeout 600

/srv/kubernetes/manifests/spinnaker-ingress.yaml:
  file.managed:
    - source: salt://kubernetes/charts/spinnaker/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

spinnaker-ingress:
    cmd.run:
      - require:
        - cmd: spinnaker
      - watch:
        - file:  /srv/kubernetes/manifests/spinnaker-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/spinnaker-ingress.yaml