{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/calico:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/usr/bin/calicoctl:
  file.managed:
    - source: https://github.com/projectcalico/calicoctl/releases/download/v{{ common.cni.calico.version }}/calicoctl-linux-amd64
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
    - source: https://github.com/projectcalico/cni-plugin/releases/download/v{{ common.cni.calico.version }}/calico-amd64
    - skip_verify: true
    - group: root
    - mode: 755

/opt/cni/bin/calico-ipam:
  file.managed:
    - source: https://github.com/projectcalico/cni-plugin/releases/download/v{{ common.cni.calico.version }}/calico-ipam-amd64
    - skip_verify: true
    - group: root
    - mode: 755

/etc/calico/kube/kubeconfig:
    file.managed:
    - source: salt://kubernetes/cni/calico/templates/kubeconfig.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 640

/srv/kubernetes/manifests/calico/calico-rbac-kkd.yaml:
    file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/calico
    - source: salt://kubernetes/cni/calico/files/calico-rbac-kkd.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/calico/calico.yaml:
    file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/calico
    - source: salt://kubernetes/cni/calico/templates/calico.yaml.j2
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
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/calico/calico-rbac-kkd.yaml 
        kubectl apply -f /srv/kubernetes/manifests/calico/calico.yaml