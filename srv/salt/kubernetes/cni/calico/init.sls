{%- set calicoCniVersion = pillar['kubernetes']['node']['networking']['calico']['cni-version'] -%}
{%- set calicoctlVersion = pillar['kubernetes']['node']['networking']['calico']['calicoctl-version'] -%}

/srv/kubernetes/manifests/calico:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/usr/bin/calicoctl:
  file.managed:
    - source: https://github.com/projectcalico/calicoctl/releases/download/{{ calicoctlVersion }}/calicoctl
    - skip_verify: true
    - group: root
    - mode: 755

/etc/calico/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/etc/calico/kube/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750


/opt/calico/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/opt/calico/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/opt/cni/bin/calico:
  file.managed:
    - source: https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico
    - skip_verify: true
    - group: root
    - mode: 755
    - require:
      - sls: node/cni

/opt/cni/bin/calico-ipam:
  file.managed:
    - source: https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-ipam
    - skip_verify: true
    - group: root
    - mode: 755
    - require:
      - sls: node/cni

/etc/calico/kube/kubeconfig:
    file.managed:
    - source: salt://kubernetes/cni/calico/templates/kubeconfig.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 640
    - require:
      - sls: node/cni

/srv/kubernetes/manifests/calico/calico.yaml:
    file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/calico
    - source: salt://kubernetes/cni/calico/templates/calico.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

query-calico-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/extensions/v1beta1'
    - match: DaemonSet
    - wait_for: 180
    - request_interval: 5
    - status: 200

calico-install:
  cmd.run:
    - require:
      - http: query-calico-required-api
    - watch:
      - file: /srv/kubernetes/manifests/calico/calico.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/calico/calico.yaml