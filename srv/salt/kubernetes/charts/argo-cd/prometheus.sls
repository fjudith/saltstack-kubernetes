argo-cd-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo-cd
    - name: /srv/kubernetes/manifests/argo-cd/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: argo-cd-namespace
        - file: /srv/kubernetes/manifests/argo-cd/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/argo-cd/prometheus-k8s-rbac.yaml

# Service Monitor Managed by the Helm charts