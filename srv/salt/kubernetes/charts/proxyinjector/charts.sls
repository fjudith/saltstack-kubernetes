{%- from "kubernetes/map.jinja" import charts with context -%}

proxyinjector-repo:
  git.latest:
    - name: https://github.com/stakater/ProxyInjector
    - target: /srv/kubernetes/manifests/proxyinjector/helm
    - force_reset: True
    - rev: v{{ charts.proxyinjector.version }}

/srv/kubernetes/manifests/proxyinjector/helm/deployments/kubernetes/chart/proxyinjector/templates/deployment.yaml:
  file.managed:
    - watch:
      - git: proxyinjector-repo
    - source: salt://kubernetes/charts/proxyinjector/patch/deployment.yaml
    - user: root
    - group: root
    - mode: 644


proxyinjector-demo-repo:
  git.latest:
    - name: https://github.com/fjudith/kubehttpbin
    - target: /srv/kubernetes/manifests/proxyinjector/kubehttpbin
    - force_reset: True
    - rev: master