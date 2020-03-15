proxyinjector-demo-namespace:
  file.managed:
    - name: /srv/kubernetes/manifests/proxyinjector/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/proxyinjector
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/proxyinjector/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/proxyinjector/namespace.yaml
