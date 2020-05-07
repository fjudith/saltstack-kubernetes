istio-namespace:
  file.managed:
    - require:
      - archive: /srv/kubernetes/manifests/istio
    - name: /srv/kubernetes/manifests/istio/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/istio/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/istio/namespace.yaml