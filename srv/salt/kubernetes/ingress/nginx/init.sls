{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/nginx:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/nginx/kube-prometheus-prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://kubernetes/ingress/nginx/files/kube-prometheus-prometheus.yaml
    - user: root
    - group: root
    - mode: 644

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

/srv/kubernetes/manifests/nginx/configuration.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://kubernetes/ingress/nginx/files/configuration.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/nginx/prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://kubernetes/ingress/nginx/files/prometheus.yaml
    - user: root
    - group: root
    - mode: 644

/srv/kubernetes/manifests/nginx/grafana.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://kubernetes/ingress/nginx/files/grafana.yaml
    - user: root
    - group: root
    - mode: 644

nginx-ingress-namespace:
  file.managed:
    - name: /srv/kubernetes/manifests/nginx/namespace.yaml
    - source: salt://kubernetes/ingress/nginx/files/namespace.yaml
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/nginx/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/namespace.yaml

nginx-ingress-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/nginx/values.yaml
      - cmd: nginx-ingress-namespace
    - name: |
        helm repo update && \
        helm upgrade --install \
          nginx \
          --namespace ingress-nginx \
          --values /srv/kubernetes/manifests/nginx/values.yaml \
          stable/nginx-ingress
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'

nginx-ingress-monitoring:
  cmd.run:
    - require:
      - cmd: nginx-ingress-install
    - watch:
      - file: /srv/kubernetes/manifests/nginx/kube-prometheus-prometheus.yaml
      - file: /srv/kubernetes/manifests/nginx/grafana-dashboard-configmap.yaml
      - file: /srv/kubernetes/manifests/nginx/configuration.yaml
      - file: /srv/kubernetes/manifests/nginx/prometheus.yaml
      - file: /srv/kubernetes/manifests/nginx/grafana.yaml
    - name: |
        {%- if common.addons.get('kube_prometheus', {'enabled': False}).enabled %}
        kubectl apply -f /srv/kubernetes/manifests/nginx/kube-prometheus-prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/grafana-dashboard-configmap.yaml
        {%- else %}
        kubectl apply -f /srv/kubernetes/manifests/nginx/configuration.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/prometheus.yaml
        kubectl apply -f /srv/kubernetes/manifests/nginx/grafana.yaml
        {%- endif %}
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

nginx-ingress-cert-manager-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/cert-manager.io'
    - match: cert-manager.io
    - wait_for: 180
    - request_interval: 5
    - status: 200

nginx-ingress-certificate:
  cmd.run:
    - require:
      - http: nginx-ingress-cert-manager-required-api
      - cmd: nginx-ingress-install
    - watch:
      - file: /srv/kubernetes/manifests/nginx/certificate.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/certificate.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'
{%- endif -%}