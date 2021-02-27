descheduler-rbac:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/descheduler/rbac.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/rbac.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

descheduler-configmap:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/descheduler/configmap.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/configmap.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

descheduler-cronjob:
  cmd.run:
    - watch:
      - cmd: descheduler-rbac
      - cmd: descheduler-configmap
      - file: /srv/kubernetes/manifests/descheduler/cronjob.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/cronjob.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose