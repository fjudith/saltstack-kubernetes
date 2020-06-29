falco-teardown:
  cmd.run:
    - name: |
        helm delete -n falco falco-exporter
        helm delete -n falco falco
  file.absent:
    - name: /srv/kubernetes/manifests/falco/certs 