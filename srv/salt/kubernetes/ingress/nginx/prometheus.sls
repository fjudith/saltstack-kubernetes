nginx-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - name: /srv/kubernetes/manifests/nginx/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: nginx-ingress-namespace
        - file: /srv/kubernetes/manifests/nginx/prometheus-k8s-rbac.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/nginx/prometheus-k8s-rbac.yaml

# Service Monitor Managed by the Helm charts