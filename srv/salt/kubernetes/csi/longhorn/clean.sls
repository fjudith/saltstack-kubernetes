longhorn-teardown:
  cmd.run:
    - runas: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/longhorn/longhorn.yaml
