# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import proxyinjector with context %}

proxyinjector-repo:
  git.latest:
    - name: https://github.com/stakater/ProxyInjector
    - target: /srv/kubernetes/manifests/proxyinjector/helm
    - force_reset: True
    - rev: v{{ proxyinjector.version }}

/srv/kubernetes/manifests/proxyinjector/helm/deployments/kubernetes/chart/proxyinjector/templates/deployment.yaml:
  file.managed:
    - watch:
      - git: proxyinjector-repo
    - source: salt://{{ tpldir }}/patch/deployment.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}


proxyinjector-demo-repo:
  git.latest:
    - name: https://github.com/fjudith/kubehttpbin
    - target: /srv/kubernetes/manifests/proxyinjector/kubehttpbin
    - force_reset: True
    - rev: master