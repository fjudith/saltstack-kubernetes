{%- from "kubernetes/map.jinja" import common with context -%}

nats-operator:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/00-prereqs.yaml
        - file: /srv/kubernetes/manifests/nats-operator/nats-operator-deployment.yaml
    - runas: root    
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/00-prereqs.yaml
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/nats-operator-deployment.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

query-nats-api:
    - watch:
      - cmd: nats-operator
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/nats.io/v1alpha2
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5

nats-cluster:
  cmd.run:
    - require:
        - cmd: query-nats-api
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/nats-cluster.yaml
    - runas: root    
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/nats-cluster.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

stan-operator:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/default-rbac.yaml
        - file: /srv/kubernetes/manifests/nats-operator/stan-operator-deployment.yaml
    - runas: root    
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/default-rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/stan-operator-deployment.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

query-stan-api:
    - watch:
      - cmd: stan-operator
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/streaming.nats.io/v1alpha1
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

stan-cluster:
  cmd.run:
    - require:
        - cmd: query-stan-api
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/stan-cluster.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/stan-cluster.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose