/srv/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/flannel.yaml:
    file.managed:
    - source: salt://node/cni/flannel/flannel.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kube-apiserver-crb.yaml:
    file.managed:
    - source: salt://kubernetes/kube-apiserver-crb/kube-apiserver-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubelet-crb.yaml:
    file.managed:
    - source: salt://kubernetes/kubelet-crb/kubelet-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/influxdb-grafana.yaml:
    file.managed:
    - source: salt://kubernetes/influxdb-grafana/influxdb-grafana.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/coredns.yaml:
    file.managed:
    - source: salt://kubernetes/coredns/coredns.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml:
    file.managed:
    - source: salt://kubernetes/dns-horizontal-autoscaler/dns-horizontal-autoscaler.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/heapster.yaml:
    file.managed:
    - source: salt://kubernetes/heapster/heapster.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kube-dashboard.yaml:
    file.managed:
    - source: salt://kubernetes/kube-dashboard/kube-dashboard.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/traefik.yaml:
    file.managed:
    - source: salt://kubernetes/traefik/traefik.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/npd.yaml:
    file.managed:
    - source: salt://kubernetes/node-problem-detector/npd.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-wait:
  cmd.run:
    - runas: root
    - name: until curl --silent 'http://127.0.0.1:8080/version/'; do printf 'Kubernetes API and extension not ready' && sleep 5; done
    - use_vt: True
    - timeout: 300

kubernetes-addon-install:
  cmd.run:
    - require:
      - cmd: flannel-wait
    - watch:
      - file: /srv/kubernetes/manifests/kube-apiserver-crb.yaml
      - file: /srv/kubernetes/manifests/kubelet-crb.yaml
      - file: /srv/kubernetes/manifests/coredns.yaml
      - file: /srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml
      - file: /srv/kubernetes/manifests/heapster.yaml
      - file: /srv/kubernetes/manifests/influxdb-grafana.yaml
      - file: /srv/kubernetes/manifests/kube-dashboard.yaml
      - file: /srv/kubernetes/manifests/traefik.yaml
      - file: /srv/kubernetes/manifests/npd.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-apiserver-crb.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubelet-crb.yaml
        kubectl apply -f /srv/kubernetes/manifests/coredns.yaml
        kubectl apply -f /srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster.yaml
        kubectl apply -f /srv/kubernetes/manifests/influxdb-grafana.yaml
        if ! curl --silent http://127.0.0.1:8080/api/v1/namespaces/kube-system/secrets | grep kubernetes-dashboard-certs ; then kubectl --namespace kube-system create secret generic kubernetes-dashboard-certs --from-file=/etc/kubernetes/ssl/dashboard-key.pem --from-file=/etc/kubernetes/ssl/dashboard.pem; fi
        kubectl apply -f /srv/kubernetes/manifests/kube-dashboard.yaml
        kubectl apply -f /srv/kubernetes/manifests/traefik.yaml
        kubectl apply -f /srv/kubernetes/manifests/npd.yaml