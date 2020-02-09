kube-prometheus-namespace:
  file.managed:
    - require:
      - git: kube-prometheus-repo
    - name: /srv/kubernetes/manifests/kube-prometheus/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/kube-prometheus/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-prometheus/namespace.yaml