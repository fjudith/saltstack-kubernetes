openfaas-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - name: /srv/kubernetes/manifests/openfaas/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: openfaas-namespace
        - file: /srv/kubernetes/manifests/openfaas/prometheus-k8s-rbac.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/openfaas/prometheus-k8s-rbac.yaml

openfaas-metrics-service:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - name: /srv/kubernetes/manifests/openfaas/gateway-metrics-service.yaml
    - source: salt://{{ tpldir }}/files/gateway-metrics-service.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: openfaas-namespace
        - file: /srv/kubernetes/manifests/openfaas/gateway-metrics-service.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/openfaas/gateway-metrics-service.yaml

openfaas-servicemonitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openfaas
    - name: /srv/kubernetes/manifests/openfaas/servicemonitor.yaml
    - source: salt://{{ tpldir }}/files/servicemonitor.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: openfaas-namespace
        - file: /srv/kubernetes/manifests/openfaas/servicemonitor.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/openfaas/servicemonitor.yaml