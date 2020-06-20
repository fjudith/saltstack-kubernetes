nuclio-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nuclio
    - name: /srv/kubernetes/manifests/nuclio/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: nuclio-namespace
        - file: /srv/kubernetes/manifests/nuclio/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/nuclio/prometheus-k8s-rbac.yaml

nuclio-service-monitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nuclio
    - name: /srv/kubernetes/manifests/nuclio/service-monitor.yaml
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: nuclio-namespace
        - file: /srv/kubernetes/manifests/nuclio/service-monitor.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/nuclio/service-monitor.yaml