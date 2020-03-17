metallb-namespace:
  file.managed:
    - name: /srv/kubernetes/manifests/metallb/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/metallb
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/metallb/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/metallb/namespace.yaml
