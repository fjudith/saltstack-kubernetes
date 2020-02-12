nginx-ingress-namespace:
  file.managed:
    - name: /srv/kubernetes/manifests/nginx/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/nginx/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/namespace.yaml