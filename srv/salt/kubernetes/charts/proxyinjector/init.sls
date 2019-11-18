{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/kubernetes/manifests/proxyinjector:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

proxyinjector-repo:
  git.latest:
    - name: https://github.com/stakater/ProxyInjector
    - target: /srv/kubernetes/manifests/proxyinjector/helm
    - force_reset: True
    - rev: v{{ charts.proxyinjector.version }}

/srv/kubernetes/manifests/proxyinjector/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/proxyinjector
    - source: salt://kubernetes/charts/proxyinjector/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja

harbor-repo:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/proxyinjector/values.yaml
    - cwd: /srv/kubernetes/manifests/proxyinjector/helm/deployments/kubernetes/chart/proxyinjector
    - runas: root
    - use_vt: true
    - name: |
        helm upgrade --install proxyinjector \
          --namespace default \
          --values /srv/kubernetes/manifests/proxyinjector/values.yaml \
          ./
