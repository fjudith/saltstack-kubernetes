concourse-prometheus-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/concourse
    - name: /srv/kubernetes/manifests/concourse/prometheus-k8s-rbac.yaml
    - source: salt://{{ tpldir }}/files/prometheus-k8s-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: concourse-namespace
        - file: /srv/kubernetes/manifests/concourse/prometheus-k8s-rbac.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/concourse/prometheus-k8s-rbac.yaml

# Service Monitor Managed by the Helm charts