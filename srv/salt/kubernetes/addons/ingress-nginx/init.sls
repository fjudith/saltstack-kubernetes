{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/ingress-nginx:
    file.recurse:
    - source: salt://kubernetes/addons/ingress-nginx/files
    - include_empty: True
    - user: root
    - group: root
    - file_mode: 644

kubernetes-nginx-install:
  cmd.run:
    - watch:
      - /srv/kubernetes/manifests/ingress-nginx/namespace.yaml
      - /srv/kubernetes/manifests/ingress-nginx/configmap.yaml
      - /srv/kubernetes/manifests/ingress-nginx/tcp-services-configmap.yaml
      - /srv/kubernetes/manifests/ingress-nginx/udp-services-configmap.yaml
      - /srv/kubernetes/manifests/ingress-nginx/rbac.yaml
      - /srv/kubernetes/manifests/ingress-nginx/default-backend.yaml
      - /srv/kubernetes/manifests/ingress-nginx/with-rbac.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/namespace.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/tcp-services-configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/udp-services-configmap.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/rbac.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/default-backend.yaml
        kubectl apply -f /srv/kubernetes/manifests/ingress-nginx/with-rbac.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
