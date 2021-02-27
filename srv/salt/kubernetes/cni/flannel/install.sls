query-fannel-api:
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/apps/v1 | grep -niE "daemonset"
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5

flannel-install:
  cmd.run:
    - require:
      - cmd: query-fannel-api
    - watch:
      - file: /srv/kubernetes/manifests/flannel/flannel.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/flannel/flannel.yaml