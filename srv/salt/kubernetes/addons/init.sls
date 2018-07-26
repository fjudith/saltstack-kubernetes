{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

kubernetes-wait:
  cmd.run:
    - runas: root
    - name: until curl --silent 'http://127.0.0.1:8080/version/'; do printf 'Kubernetes API and extension not ready' && sleep 5; done
    - use_vt: True
    - timeout: 300

/srv/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/flannel.yaml:
    file.managed:
    - source: salt://kubernetes/cni/flannel/flannel.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{# Kubernetes: cluster role bindings #}
/srv/kubernetes/manifests/kube-apiserver-crb.yaml:
    file.managed:
    - source: salt://kubernetes/addons/kube-apiserver-crb/kube-apiserver-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubelet-crb.yaml:
    file.managed:
    - source: salt://kubernetes/addons/kubelet-crb/kubelet-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-role-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - file: /srv/kubernetes/manifests/kube-apiserver-crb.yaml
      - file: /srv/kubernetes/manifests/kubelet-crb.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-apiserver-crb.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubelet-crb.yaml

{# Kubernetes addon: heapster influxdb grafana #}
{%- if common.addons.get('heapster-influxdb', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/heapster.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/heapster.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/heapster-rbac.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/heapster-rbac.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/heapster-service.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/heapster-service.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/influxdb-grafana.yaml:
    file.managed:
    - source: salt://kubernetes/addons/influxdb-grafana/influxdb-grafana.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-heapster-influxdb-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/heapster.yaml
      - /srv/kubernetes/manifests/heapster-rbac.yaml
      - /srv/kubernetes/manifests/heapster-service.yaml
      - /srv/kubernetes/manifests/influxdb-grafana.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/heapster.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/heapster-service.yaml
        kubectl apply -f /srv/kubernetes/manifests/influxdb-grafana.yaml
{% endif %}

{# Kubernetes addon: kubernetes coredns #}
{%- if common.addons.dns.get('coredns', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/coredns.yaml:
    file.managed:
    - source: salt://kubernetes/addons/coredns/coredns.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-coredns-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/coredns.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/coredns.yaml
{% endif %}

{# Kubernetes addon: dns autoscaler #}
{%- if common.addons.dns.get('autoscaler', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml:
    file.managed:
    - source: salt://kubernetes/addons/dns-horizontal-autoscaler/dns-horizontal-autoscaler.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-dns-horizontal-autoscaler-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/dns-horizontal-autoscaler.yaml
{% endif %}

{# Kubernetes addon: kubernetes dashboard #}
{%- if common.addons.get('dashboard', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/kube-dashboard.yaml:
    file.managed:
    - source: salt://kubernetes/addons/kube-dashboard/kube-dashboard.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-dashboard-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/kube-dashboard.yaml
    - name: |
        if ! curl --silent http://127.0.0.1:8080/api/v1/namespaces/kube-system/secrets | grep kubernetes-dashboard-certs ; then kubectl --namespace kube-system create secret generic kubernetes-dashboard-certs --from-file=/etc/kubernetes/ssl/dashboard-key.pem --from-file=/etc/kubernetes/ssl/dashboard.pem; fi
        kubectl apply -f /srv/kubernetes/manifests/kube-dashboard.yaml
{% endif %}

{# Kubernetes addon: traefik #}
{%- if common.addons.get('ingress_traefik', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/traefik.yaml:
    file.managed:
    - source: salt://kubernetes/addons/traefik/traefik.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-traefik-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/traefik.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/traefik.yaml
{% endif %}


{# Kubernetes addon: node problem detector #}
{%- if common.addons.get('npd', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/npd.yaml:
    file.managed:
    - source: salt://kubernetes/addons/node-problem-detector/npd.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-npd-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/npd.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/npd.yaml
{% endif %}

{%- if common.addons.get('ingress-nginx', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/ingress-nginx:
    file.recurse:
    - source: salt://kubernetes/addons/ingress-nginx
    - include_empty: True
    - user: root
    - template: jinja
    - group: root
    - file_mode: 644

kubernetes-nginx-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - /srv/kubernetes/manifests/ingress-nginx/namespace.yaml
      - /srv/kubernetes/manifests/ingress-nginx/configmap.yaml
      - /srv/kubernetes/manifests/ingress-nginx/tcp-services-configmap.yaml
      - /srv/kubernetes/manifests/ingress-nginx/udp-services-configmap.yaml
      - /srv/kubernetes/manifests/ingress-nginx/rbac.yaml
      - /srv/kubernetes/manifests/ingress-nginx/default-backend.yaml
      - /srv/kubernetes/manifests/ingress-nginx/with-rbac.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/namespace.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/tcp-services-configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/udp-services-configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/default-backend.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/with-rbac.yaml
{% endif %}

{# Kubernetes addon: fluentd-elasticsearch #}
{%- if common.addons.get('fluentd-elasticsearch', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/fluentd-elasticsearch:
    file.recurse:
    - source: salt://kubernetes/addons/fluentd-elasticsearch
    - include_empty: True
    - user: root
    - template: jinja
    - group: root
    - file_mode: 644

kubernetes-fluentd-elasticsearch-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - file: /srv/kubernetes/manifests/fluentd-elasticsearch
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/fluentd-elasticsearch/
{% endif %}

{# Kubernetes addon: kube-prometheus #}
{%- if common.addons.get('kube-prometheus', {'enabled': False}).enabled %}
addon-prometheus-operator:
  git.latest:
    - name: https://github.com/coreos/prometheus-operator
    - target: /srv/kubernetes/manifests/prometheus-operator
    - force_reset: True
    - rev: v0.22.0

/srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/kube-prometheus-ingress.yaml:
    file.managed:
    - source: salt://kubernetes/addons/prometheus-operator/kube-prometheus-ingress.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: addon-prometheus-operator

kubernetes-kube-prometheus-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
        - git:  addon-prometheus-operator
        - file: /srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/kube-prometheus-ingress.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/prometheus-operator/contrib/kube-prometheus/manifests/
{% endif %}

{# Kubernetes addon: Helm #}
{%- if common.addons.get('helm', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/helm:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/helm/helm-rbac.yaml:
    file.recurse:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/helm-rbac.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/helm/helm-tiller.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/helm-tiller.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/helm/helm-serviceaccount.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/helm
    - source: salt://kubernetes/addons/helm/helm-serviceaccount.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-helm-install:
  cmd.run:
    - require:
      - cmd: kubernetes-wait
    - watch:
      - file: /srv/kubernetes/manifests/helm/helm-rbac.yaml
      - file: /srv/kubernetes/manifests/helm/helm-tiller.yaml
      - file: /srv/kubernetes/manifests/helm/helm-serviceaccount.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/helm/helm-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/helm/helm-tiller.yaml
        kubectl apply -f /srv/kubernetes/manifests/helm/helm-serviceaccount.yaml
{% endif %}