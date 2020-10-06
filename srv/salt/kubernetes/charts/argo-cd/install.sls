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

argo-cd-wait-api:
  http.wait_for_successful_query:
    - name: 'http://localhost:8080/apis/argoproj.io/v1alpha1/'
    - match: Sensor
    - wait_for: 60
    - request_interval: 5
    - status: 200


argo-cd-password:
  cmd.run:
    - runas: root
    - watch:
      - http: argo-cd-wait-api
      - file: /usr/local/bin/argocd
      - cmd: argo-cd
    - name: |
        PASSWD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
        argocd login http://localhost:8001/api/v1/namespaces/argo-cd/services/https:argo-cd-argocd-server:https/proxy --password ${PASSWD}
