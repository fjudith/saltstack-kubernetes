{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

addon-harbor:
  git.latest:
    - name: https://github.com/goharbor/harbor-helm
    - target: /srv/kubernetes/manifests/harbor
    - force_reset: True
    - rev: {{ common.addons.harbor.version }}

kubernetes-harbor-install:
  cmd.run:
    - watch:
        - git:  addon-harbor
    - runas: root
    - unless: helm list | grep registry
    - cwd: /srv/kubernetes/manifests/harbor
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm dependency update
        helm install --name registry --namespace harbor \
        {%- if master.storage.get('rook', {'enabled': False}).enabled %}
        --set persistence.enabled=true \
        --set jobservice.volumes.data.storageClass=rook-ceph-block \
        --set database.internal.volumes.data.storageClass=rook-ceph-block \
        --set registry.volumes.data.storageClass=rook-ceph-block \
        --set chartmuseum.volumes.data.storageClass=rook-ceph-block \
        --set redis.internal.volumes.data.storageClass=rook-ceph-block \
        {%- else -%}
        --set persistence.enabled=false \
        {%- endif %}
        --set harborAdminPassword={{ common.addons.harbor.admin_password }} \
        --set secretkey={{ common.addons.harbor.secretkey }} \
        --set externalURL=https://registry.{{ public_domain }} \
        "./"

{% if common.addons.get('ingress_istio', {'enabled': False}).enabled -%}
/srv/kubernetes/manifests/harbor-virtualservice.yaml:
    file.managed:
    - source: salt://kubernetes/addons/harbor/virtualservice.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

harbor-virtualservice:
  cmd.run:
    - watch:
        - file:  /srv/kubernetes/manifests/harbor-virtualservice.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
    - name: kubectl apply -f /srv/kubernetes/manifests/harbor-virtualservice.yaml
{% endif %}