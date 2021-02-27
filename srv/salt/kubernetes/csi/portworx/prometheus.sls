portworx-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/portworx
    - name: /srv/kubernetes/manifests/portworx/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: portworx
        - file: /srv/kubernetes/manifests/portworx/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/portworx/prometheus-k8s-rbac.yaml

portworx-servicemonitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/portworx
    - name: /srv/kubernetes/manifests/portworx/service-monitor.yaml
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: portworx
        - file: /srv/kubernetes/manifests/portworx/service-monitor.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/portworx/service-monitor.yaml