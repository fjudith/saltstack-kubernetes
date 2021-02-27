query-kube-prometheus-required-api:
  cmd.run:
    - watch:
        - cmd: kube-prometheus
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/monitoring.coreos.com
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10