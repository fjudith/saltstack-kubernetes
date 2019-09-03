{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests/cert-manager:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/cert-manager/namespace.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - source: salt://kubernetes/ingress/cert-manager/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/cert-manager/cert-manager.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - source: https://github.com/jetstack/cert-manager/releases/download/v{{ common.addons.cert_manager.version }}/cert-manager.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - skip_verify: true

/srv/kubernetes/manifests/cert-manager/clusterissuer.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cert-manager
    - source: salt://kubernetes/ingress/cert-manager/templates/{{ common.addons.cert_manager.dns.provider }}-clusterissuer.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-cert-manager-install:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/cert-manager/cert-manager.yaml
        - file: /srv/kubernetes/manifests/cert-manager/namespace.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/namespace.yaml && \
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/cert-manager.yaml && \
        kubectl -n cert-manager delete secret public-dns-secret & \
        kubectl -n cert-manager create secret generic public-dns-secret --from-literal=secret-access-key="{{ common.addons.cert_manager.dns.secret }}"

query-cert-manager-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/certmanager.k8s.io'
    - match: certmanager.k8s.io
    - wait_for: 180
    - request_interval: 5
    - status: 200

kubernetes-cert-manager-config:
  cmd.run:
    - require:
      - cmd: kubernetes-cert-manager-install
      - http: query-cert-manager-required-api
    - watch:
        - file: /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/apis/certmanager.k8s.io'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml