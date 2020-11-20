# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import jenkins with context %}
{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}
{%- from "kubernetes/map.jinja" import storage with context -%}

jenkins:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/jenkins/values.yaml
      - cmd: jenkins-namespace
      - cmd: jenkins-fetch-charts
    - onlyif: kubectl get storageclass | grep \(default\)
    - cwd: /srv/kubernetes/manifests/jenkins/jenkins
    - name: |
        helm repo update && \
        helm upgrade --install jenkins --namespace jenkins \
            -f /srv/kubernetes/manifests/jenkins/values.yaml \
            "./" --wait --timeout 5m
