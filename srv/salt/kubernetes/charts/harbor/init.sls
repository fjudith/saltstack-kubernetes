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

harbor:
  cmd.run:
    - watch:
        - git:  harbor-repo
    - runas: root
    - unless: helm list | grep harbor
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm dependency update
        helm install --name harbor --namespace harbor \
          --set export.type=clusterIP \
          --set expose.ingress.hosts.core={{ charts.harbor.core_ingress_host }}.{{ public_domain }} \
          --set expose.ingress.hosts.notary={{ charts.harbor.notary_ingress_host }}.{{ public_domain }} \
          --set externalURL=https://{{ charts.harbor.core_ingress_host }}.{{ public_domain }} \
          {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
          --set persistence.enabled=true \
          --set database.internal.volumes.data.storageClass=rook-ceph-block \
          --set registry.volumes.data.storageClass=rook-ceph-block \
          --set chartmuseum.volumes.data.storageClass=rook-ceph-block \
          --set redis.master.persistence.storageClass=rook-ceph-block \
          {%- else -%}
          --set persistence.enabled=false \
          {%- endif %}
          --set database.internal.password={{ charts.harbor.database_password }} \
          --set harborAdminPassword={{ charts.harbor.admin_password }} \
          --set secretKey={{ charts.harbor.secretkey }} \
          "./"

harbor-ingress:
    cmd.run:
      - require:
        - cmd: harbor
      - watch:
        - file: /srv/kubernetes/manifests/harbor-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/harbor-ingress.yaml