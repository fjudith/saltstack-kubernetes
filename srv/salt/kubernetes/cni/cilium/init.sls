/srv/kubernetes/manifests/cilium:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/etc/kubernetes/ssl/ca.crt:
  file.symlink:
    - target: /etc/kubernetes/ssl/ca.pem

/etc/kubernetes/ssl/client.key:
  file.symlink:
    - target: /etc/kubernetes/ssl/master-key.pem

/etc/kubernetes/ssl/client.crt:
  file.symlink:
    - target: /etc/kubernetes/ssl/master.pem

/srv/kubernetes/manifests/cilium/cilium.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cilium
    - source: salt://kubernetes/cni/cilium/templates/cilium.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

cilium-etcd-cert:
  cmd.run:
    - require:
      - file: /etc/kubernetes/ssl/ca.crt
      - file: /etc/kubernetes/ssl/client.key
      - file: /etc/kubernetes/ssl/client.crt
      - file: /srv/kubernetes/manifests/cilium/cilium.yaml
    - runas: root
    - env:
      - CA_CERT: /etc/kubernetes/ssl/ca.pem
      - SERVER_KEY: /etc/kubernetes/ssl/client.key
      - SERVER_CERT: /etc/kubernetes/ssl/client.crt
    - unless: curl http://localhost:8001/api/v1/namespaces/kube-system/secrets/cilium-etcd-secrets
    - name: kubectl create secret generic -n kube-system cilium-etcd-secrets --from-file=etcd-ca=${CA_CERT} --from-file=etcd-client-key=${SERVER_KEY} --from-file=etcd-client-crt=${SERVER_CERT}


query-cilium-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1'
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