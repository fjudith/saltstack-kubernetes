contour-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/contour
    - name: /srv/kubernetes/manifests/contour/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: contour-namespace
        - file: /srv/kubernetes/manifests/contour/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/contour/prometheus-k8s-rbac.yaml

# Service Monitor Managed by the Helm charts