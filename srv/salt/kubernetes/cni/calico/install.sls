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
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://127.0.0.1:6443/apis/apps/v1 | grep -niE "daemonset"
    - use_vt: True
    - retry:
        attempts: 10
        until: True
        interval: 5
        splay: 10

calico-install:
  cmd.run:
    - require:
      - cmd: query-calico-required-api
    - watch:
      - file: /srv/kubernetes/manifests/calico/calico-typha.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/calico/calico-typha.yaml
