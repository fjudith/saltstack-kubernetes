nats-operator-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - name: /srv/kubernetes/manifests/nats-operator/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: nats-operator-namespace
        - file: /srv/kubernetes/manifests/nats-operator/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/nats-operator/prometheus-k8s-rbac.yaml

nats-operator-servicemonitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - name: /srv/kubernetes/manifests/nats-operator/servicemonitor.yaml
    - source: salt://{{ tpldir }}/files/servicemonitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: nats-operator-namespace
        - file: /srv/kubernetes/manifests/nats-operator/servicemonitor.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/nats-operator/servicemonitor.yaml