argo-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: argo-namespace
        - file: /srv/kubernetes/manifests/argo/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/argo/prometheus-k8s-rbac.yaml

# Service Monitor Managed by the Helm charts