{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/nginx:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/nginx/grafana-dashboard-configmap.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://kubernetes/ingress/nginx/files/grafana-dashboard-configmap.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/nginx/values.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://kubernetes/ingress/nginx/files/values.yaml
    - user: root
    - group: root
    - mode: 644

kubernetes-nginx-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/nginx/values.yaml
    - name: |
        helm upgrade --install \
          nginx \
          --namespace ingress-nginx \
          --values /srv/kubernetes/manifests/nginx/values.yaml \
          stable/nginx-ingress
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

kubernetes-nginx-dashboard:
  cmd.run:
    - require:
      - cmd: kubernetes-nginx-install
    - watch:
      - file: /srv/kubernetes/manifests/nginx/grafana-dashboard-configmap.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/grafana-dashboard-configmap.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

{% if common.addons.get('cert_manager', {'enabled': False}).enabled %}
/srv/kubernetes/manifests/nginx/certificate.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://kubernetes/ingress/nginx/templates/certificate.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

kubernetes-nginx-cert-manager-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/certmanager.k8s.io'
    - match: certmanager.k8s.io
    - wait_for: 180
    - request_interval: 5
    - status: 200

kubernetes-nginx-certificate:
  cmd.run:
    - require:
      - http: kubernetes-nginx-cert-manager-required-api
      - cmd: kubernetes-nginx-install
    - watch:
      - file: /srv/kubernetes/manifests/nginx/certificate.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/certificate.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
{%- endif -%}