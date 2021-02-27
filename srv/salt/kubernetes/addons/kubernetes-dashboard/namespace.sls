kubernetes-dashboard-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kubernetes-dashboard
    - name: /srv/kubernetes/manifests/kubernetes-dashboard/dashboard-namespace.yaml
    - source: salt://{{ tpldir }}/files/dashboard-namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubernetes-dashboard/dashboard-namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubernetes-dashboard/dashboard-namespace.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose