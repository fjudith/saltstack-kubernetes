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
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/apps/v1'
    - match: DaemonSet
    - wait_for: 180
    - request_interval: 5
    - status: 200

cilium-install:
  cmd.run:
    - require:
      - http: query-cilium-required-api
    - watch:
      - file: /srv/kubernetes/manifests/cilium/cilium.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/cilium/cilium.yaml