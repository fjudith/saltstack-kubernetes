# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import openebs with context %}
{%- set nodes = [] -%}
{%- for key, value in salt["mine.get"](tgt="role:node", fun="network.get_hostname", tgt_type="grain")|dictsort(false, 'value') -%}
  {%- do nodes.append(value) -%}
{%- endfor -%}

rook-ceph-teardown:
  cmd.run:
    - user: root
    - name: |
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/prometheus-ceph-rules.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/prometheus.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/prometheus-service.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/prometheus-service-monitor.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/ceph-exporter-service-monitor.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/ceph-exporter.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/filesystem-storageclass.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/filesystem.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/object.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/storageclass.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/pool.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/cluster.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/operator.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/common.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/toolbox.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/ingress.yaml
        kubectl -n rook-ceph delete -f /srv/kubernetes/manifests/rook-ceph/namespace.yaml




