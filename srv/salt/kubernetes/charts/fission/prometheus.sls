fission-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/fission
    - name: /srv/kubernetes/manifests/fission/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: fission-namespace
        - file: /srv/kubernetes/manifests/fission/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/fission/prometheus-k8s-rbac.yaml

fission-service-monitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/fission
    - name: /srv/kubernetes/manifests/fission/service-monitor.yaml
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: fission-namespace
        - file: /srv/kubernetes/manifests/fission/service-monitor.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/fission/service-monitor.yaml