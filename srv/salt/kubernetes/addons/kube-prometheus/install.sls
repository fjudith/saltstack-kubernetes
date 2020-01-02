kube-prometheus:
  cmd.run:
    - watch:
      - git:  kube-prometheus-repo
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/setup && \
        until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done && \
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

kube-prometheus-grafana:
  file.managed:
    - name: /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - source: salt://kubernetes/addons/kube-prometheus/patch/grafana-deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - watch:
      - git: kube-prometheus-repo
  cmd.run:
    - watch:
        - cmd: kube-prometheus
        - file: /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/manifests/grafana-deployment.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'