kube-prometheus-crds:
  cmd.run:
    - watch:
      - git: kube-prometheus-repo
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/setup/
        until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
    - unless: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/monitoring.coreos.com/v1
    - timeout: 60

kube-prometheus-query-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/monitoring.coreos.com/v1/servicemonitors | grep -niE "servicemonitorlist"
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5

kube-prometheus:
  cmd.run:
    - watch:
      - git: kube-prometheus-repo
      - cmd: kube-prometheus-query-api
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/ --validate=false
    - onlyif: http --verify false https://localhost:6443/livez?verbose