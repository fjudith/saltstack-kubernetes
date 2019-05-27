{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

harbor-repo:
  git.latest:
    - name: https://github.com/goharbor/harbor-helm
    - target: /srv/kubernetes/manifests/harbor
    - force_reset: True
    - rev: v{{ charts.harbor.version }}

/srv/kubernetes/manifests/harbor-ingress.yaml:
    file.managed:
    - source: salt://kubernetes/charts/harbor/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

harbor-namespace:
  cmd.run:
    - unless: kubectl get namespace harbor
    - name: |
        kubectl create namespace harbor

harbor:
  cmd.run:
    - watch:
        - git: harbor-repo
    - require:
      - cmd: harbor-namespace
    - runas: root
    - unless: helm list | grep harbor
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - HELM_HOME: /srv/helm/home
    - use_vt: true
    - name: |
        helm dependency update
        helm template . \
          --name harbor \
          --namespace harbor \
          --set export.type=clusterIP \
          --set expose.ingress.hosts.core={{ charts.harbor.core_ingress_host }}.{{ public_domain }} \
          --set expose.ingress.hosts.notary={{ charts.harbor.notary_ingress_host }}.{{ public_domain }} \
          --set externalURL=https://{{ charts.harbor.core_ingress_host }}.{{ public_domain }} \
          {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
          --set persistence.enabled=true \
          --set persistence.persistentVolumeClaim.registry.storageClass=rook-ceph-block \
          --set persistence.persistentVolumeClaim.chartmuseum.storageClass=rook-ceph-block \
          --set persistence.persistentVolumeClaim.jobservice.storageClass=rook-ceph-block \
          --set persistence.persistentVolumeClaim.database.storageClass=rook-ceph-block \
          --set persistence.persistentVolumeClaim.redis.storageClass=rook-ceph-block \
          --set chartmuseum.volumes.data.storageClass=rook-ceph-block \
          --set redis.master.persistence.storageClass=rook-ceph-block \
          {%- else -%}
          --set persistence.enabled=false \
          {%- endif %}
          {%- if master.storage.get('rook_minio', {'enabled': False}).enabled %}
          --set imageChartStorage.disableredirect=true \
          --set imageChartStorage.type=s3 \
          --set imageChartStorage.s3.bucket={{ charts.harbor.bucket }} \
          --set imageChartStorage.s3.accesskey={{ master.storage.rook_minio.username }} \
          --set imageChartStorage.s3.secretkey={{ master.storage.rook_minio.password }} \
          --set imageChartStorage.s3.regionendpoint=https://{{ master.storage.rook_minio.ingress_host }}.{{ public_domain }} \
          {%- endif %}
          --set database.internal.password={{ charts.harbor.database_password }} \
          --set harborAdminPassword={{ charts.harbor.admin_password }} \
          --set secretKey={{ charts.harbor.secretkey }} | kubectl apply --namespace harbor --validate=false -f -

harbor-ingress:
    cmd.run:
      - require:
        - cmd: harbor
      - watch:
        - file: /srv/kubernetes/manifests/harbor-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/harbor-ingress.yaml