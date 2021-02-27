cert-manager-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - name: /srv/kubernetes/manifests/cert-manager/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/cert-manager/namespace.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/cert-manager/namespace.yaml