cilium-etcd-cert:
  cmd.run:
    - require:
      - file: /srv/kubernetes/manifests/cilium/cilium.yaml
    - runas: root
    - env:
      - CA_CERT: /etc/kubernetes/pki/etcd/ca.crt
      - SERVER_KEY: /etc/kubernetes/pki/apiserver-etcd-client.key
      - SERVER_CERT: /etc/kubernetes/pki/apiserver-etcd-client.crt
    - unless: curl http://localhost:8001/api/v1/namespaces/kube-system/secrets/cilium-etcd-secrets
    - name: kubectl create secret generic -n kube-system cilium-etcd-secrets --from-file=etcd-ca=${CA_CERT} --from-file=etcd-client-key=${SERVER_KEY} --from-file=etcd-client-crt=${SERVER_CERT}

query-cilium-required-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/apps/v1 | grep -niE "daemonset"
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5

cilium-install:
  cmd.run:
    - require:
      - cmd: query-cilium-required-api
    - watch:
      - file: /srv/kubernetes/manifests/cilium/cilium.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/cilium/cilium.yaml