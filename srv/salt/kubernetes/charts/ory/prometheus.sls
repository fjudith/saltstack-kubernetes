ory-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/ory
    - name: /srv/kubernetes/manifests/ory/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: ory-namespace
        - file: /srv/kubernetes/manifests/ory/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/ory/prometheus-k8s-rbac.yaml

ory-servicemonitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/ory
    - name: /srv/kubernetes/manifests/ory/service-monitor.yaml
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: ory-namespace
        - file: /srv/kubernetes/manifests/ory/service-monitor.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/ory/service-monitor.yaml
