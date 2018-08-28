{%- from "kubernetes/map.jinja" import etcd with context -%}
{%- from "kubernetes/map.jinja" import common with context -%}

/etc/kubernetes/manifests/flannel.yaml:
    file.managed:
    - source: salt://kubernetes/cni/flannel/flannel.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

flannel-etcd-config:
  cmd.run:
    - require:
      - file: /etc/kubernetes/manifests/flannel.yaml
    - runas: root
    - env:
      - ACTIVE_ETCD: https://{{ etcd.members[0].host }}:2379
    - name: |
        curl --cacert /etc/kubernetes/ssl/ca.pem --key /etc/kubernetes/ssl/master-key.pem --cert /etc/kubernetes/ssl/master.pem --silent -X PUT -d "value={\"Network\":\"{{ common.cni.network }}\",\"Backend\":{\"Type\":\"vxlan\"}}" "https://{{ etcd.members[0].host }}:2379/v2/keys/coreos.com/network/config?prevExist=false"

query-fannel-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1'
    - match: DaemonSet
    - wait_for: 900
    - request_interval: 5
    - status: 200

flannel-install:
  cmd.run:
    - require:
      - cmd: flannel-etcd-config
      - http: query-fannel-required-api
    - watch:
      - file: /etc/kubernetes/manifests/flannel.yaml
    - runas: root
    - name: kubectl apply -f /etc/kubernetes/manifests/flannel.yaml