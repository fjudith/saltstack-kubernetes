descheduler-job:
  cmd.run:
    - watch:
      - cmd: descheduler-rbac
      - cmd: descheduler-configmap
      - file: /srv/kubernetes/manifests/descheduler/job.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/job.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'