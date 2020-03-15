{%- from tpldir ~ "/map.jinja" import calico with context -%}

/usr/bin/calicoctl:
  file.managed:
    - source: https://github.com/projectcalico/calicoctl/releases/download/v{{ calico.version }}/calicoctl-linux-amd64
    - skip_verify: true
    - group: root
    - mode: "0755"

/opt/cni/bin/calico:
  file.managed:
    - source: https://github.com/projectcalico/cni-plugin/releases/download/v{{ calico.version }}/calico-amd64
    - skip_verify: true
    - group: root
    - mode: "0755"

/opt/cni/bin/calico-ipam:
  file.managed:
    - source: https://github.com/projectcalico/cni-plugin/releases/download/v{{ calico.version }}/calico-ipam-amd64
    - skip_verify: true
    - group: root
    - mode: "0755"

query-calico-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/apps/v1'
    - match: DaemonSet
    - wait_for: 180
    - request_interval: 5
    - status: 200

calico-install:
  cmd.run:
    - require:
      - http: query-calico-required-api
    - watch:
      - file: /srv/kubernetes/manifests/calico/calico-typha.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/calico/calico-rbac-kkd.yaml 
        kubectl apply -f /srv/kubernetes/manifests/calico/calico-typha.yaml
