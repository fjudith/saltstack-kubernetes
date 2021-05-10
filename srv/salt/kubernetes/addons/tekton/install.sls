# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import rook_yugabytedb with context %}

tekton:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/tekton/release.yaml
        - cmd: tekton-namespace
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/tekton/release.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

query-tekton-api:
  cmd.run:
    - watch:
      - cmd: tekton
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/operator.tekton.dev/v1alpha1
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5

tekton-resources:
  cmd.run:
    - require:
        - cmd: query-tekton-api
        - cmd: tekton-namespace
    - watch:
        - file: /srv/kubernetes/manifests/tekton/operator_v1alpha1_dashboard_cr.yaml
        - file: /srv/kubernetes/manifests/tekton/operator_v1alpha1_pipeline_cr.yaml
        - file: /srv/kubernetes/manifests/tekton/operator_v1alpha1_trigger_cr.yaml
    - runas: root    
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/tekton/operator_v1alpha1_dashboard_cr.yaml
        kubectl apply -f /srv/kubernetes/manifests/tekton/operator_v1alpha1_pipeline_cr.yaml
        kubectl apply -f /srv/kubernetes/manifests/tekton/operator_v1alpha1_trigger_cr.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose