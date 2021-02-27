descheduler-job:
  cmd.run:
    - watch:
      - cmd: descheduler-rbac
      - cmd: descheduler-configmap
      - file: /srv/kubernetes/manifests/descheduler/job.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/job.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose