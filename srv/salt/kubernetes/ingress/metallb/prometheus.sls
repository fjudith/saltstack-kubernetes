metallb-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/metallb
    - name: /srv/kubernetes/manifests/metallb/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: metallb-namespace
        - file: /srv/kubernetes/manifests/metallb/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/metallb/prometheus-k8s-rbac.yaml