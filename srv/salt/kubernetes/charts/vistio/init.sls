{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

addon-vistio:
  git.latest:
    - name: https://github.com/nmnellis/vistio
    - target: /srv/kubernetes/manifests/vistio
    - force_reset: True
    - rev: v{{ charts.vistio.version }}

/srv/kubernetes/manifests/vistio-ingress.yaml:
    file.managed:
    - source: salt://kubernetes/charts/vistio/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-vistio-install:
  cmd.run:
    - watch:
        - git:  addon-vistio
        - file: /srv/kubernetes/manifests/vistio-ingress.yaml
    - runas: root
    - unless: helm list | grep vistio
    - cwd: /srv/kubernetes/manifests/vistio
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name vistio --namespace default \
          --values helm/vistio/values-with-ingress.yaml \
          --set web.env.updateURL=https://{{ charts.vistio.ingress_host }}-api.{{ public_domain }}/graph \
          {%- if master.storage.get('rook_ceph', {'enabled': False}).enabled %}
          --set api.storage.class=rook-ceph-block \
          {%- endif %}
          "helm/vistio"
        kubectl apply -f /srv/kubernetes/manifests/vistio-ingress.yaml