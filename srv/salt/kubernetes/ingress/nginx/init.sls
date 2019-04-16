{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/nginx:
    file.recurse:
    - source: salt://kubernetes/ingress/nginx/files
    - include_empty: True
    - user: root
    - group: root
    - file_mode: 644

kubernetes-nginx-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/nginx/namespace.yaml
      - /srv/kubernetes/manifests/nginx/configmap.yaml
      - /srv/kubernetes/manifests/nginx/tcp-services-configmap.yaml
      - /srv/kubernetes/manifests/nginx/udp-services-configmap.yaml
      - /srv/kubernetes/manifests/nginx/rbac.yaml
      - /srv/kubernetes/manifests/nginx/default-backend.yaml
      - /srv/kubernetes/manifests/nginx/with-rbac.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/namespace.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/tcp-services-configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/udp-services-configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/default-backend.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/with-rbac.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
