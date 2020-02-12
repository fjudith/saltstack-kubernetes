nginx-ingress-monitoring:
  cmd.run:
    - require:
      - cmd: nginx-ingress-install
    - watch:
      - file: /srv/kubernetes/manifests/nginx/configuration.yaml
      - file: /srv/kubernetes/manifests/nginx/prometheus.yaml
      - file: /srv/kubernetes/manifests/nginx/grafana.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/configuration.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/grafana.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'