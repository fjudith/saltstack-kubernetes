cert-manager-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - name: /srv/kubernetes/manifests/cert-manager/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: cert-manager-namespace
        - file: /srv/kubernetes/manifests/cert-manager/prometheus-k8s-rbac.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/cert-manager/prometheus-k8s-rbac.yaml

cert-manager-servicemonitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - name: /srv/kubernetes/manifests/cert-manager/servicemonitor.yaml
    - source: salt://{{ tpldir }}/files/servicemonitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: cert-manager-namespace
        - file: /srv/kubernetes/manifests/cert-manager/servicemonitor.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/cert-manager/servicemonitor.yaml