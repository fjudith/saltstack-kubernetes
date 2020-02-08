descheduler-rbac:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/descheduler/rbac.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/rbac.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

descheduler-configmap:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/descheduler/configmap.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/configmap.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'

descheduler-cronjob:
  cmd.run:
    - watch:
      - cmd: descheduler-rbac
      - cmd: descheduler-configmap
      - file: /srv/kubernetes/manifests/descheduler/cronjob.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/descheduler/cronjob.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'