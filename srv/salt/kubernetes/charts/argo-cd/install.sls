# -*- coding: utf-8 -*-
# vim: ft=jinja

{#- Get the `tplroot` from `tpldir` #}
{% from tpldir ~ "/map.jinja" import argo_cd with context %}

/opt/argocd-linux-amd64-v{{ argo_cd.version }}:
  file.managed:
    - source: https://github.com/argoproj/argo-cd/releases/download/v{{ argo_cd.version }}/argocd-linux-amd64
    - skip_verify: True
    - mode: "0755"
    - user: root
    - group: root
    - if_missing: /opt/argocd-linux-amd64-v{{ argo_cd.version }}

/usr/local/bin/argocd:
  file.symlink:
    - target: /opt/argocd-linux-amd64-v{{ argo_cd.version }}

/srv/kubernetes/manifests/argo-cd/values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo-cd
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

argo-cd:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo-cd/values.yaml
      - cmd: argo-cd-namespace
      - cmd: argo-cd-fetch-charts
    - cwd: /srv/kubernetes/manifests/argo-cd/argo-cd
    - name: |
        kubectl apply -f ./crds/ && \
        helm upgrade --install argo-cd --namespace argocd \
            --values /srv/kubernetes/manifests/argo-cd/values.yaml \
            "./" --wait --timeout 5m

query-argo-cd-api:
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/argoproj.io/v1alpha1/ | grep -niE "sensor"
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5


argo-cd-password:
  cmd.run:
    - runas: root
    - watch:
      - cmd: query-argo-cd-api
      - file: /usr/local/bin/argocd
      - cmd: argo-cd
    - name: |
        PASSWD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
        argocd login http://localhost:8001/api/v1/namespaces/argo-cd/services/https:argo-cd-argocd-server:https/proxy --password ${PASSWD}
