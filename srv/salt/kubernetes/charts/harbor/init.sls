{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

addon-harbor:
  git.latest:
    - name: https://github.com/goharbor/harbor-helm
    - target: /srv/kubernetes/manifests/harbor
    - force_reset: True
    - rev: {{ charts.harbor.version }}

/srv/kubernetes/manifests/harbor-ingress.yaml:
    file.managed:
    - source: salt://kubernetes/charts/harbor/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-harbor-install:
  cmd.run:
    - watch:
        - git:  addon-harbor
        - file: /srv/kubernetes/manifests/harbor-ingress.yaml
    - runas: root
    - unless: helm list | grep registry
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm dependency update
        helm install --name registry --namespace harbor \
          --set database.internal.password={{ charts.harbor.database_password }} \
          {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
          --set persistence.enabled=true \
          --set database.internal.volumes.data.storageClass=rook-ceph-block \
          --set registry.volumes.data.storageClass=rook-ceph-block \
          --set chartmuseum.volumes.data.storageClass=rook-ceph-block \
          --set redis.master.persistence.storageClass=rook-ceph-block \
          {%- else -%}
          --set persistence.enabled=false \
          {%- endif %}
          --set harborAdminPassword={{ charts.harbor.admin_password }} \
          --set secretkey={{ charts.harbor.secretkey }} \
          --set externalURL=https://registry.{{ public_domain }} \
          "./"
        kubectl apply -f /srv/kubernetes/manifests/harbor-ingress.yaml