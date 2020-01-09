nats-operator-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nats-operator
    - name: /srv/kubernetes/manifests/nats-operator/namespace.yaml
    - source: salt://kubernetes/addons/nats-operator/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/nats-operator/namespace.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nats-operator/namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'