{%- from "kubernetes/map.jinja" import common with context -%}

addon-cert-manager:
  git.latest:
    - name: https://github.com/jetstack/cert-manager
    - target: /srv/kubernetes/manifests/cert-manager
    - force_reset: True
    - rev: v{{ common.addons.cert_manager.version }}

/srv/kubernetes/manifests/cert-manager/clusterissuer.yaml:
  file.managed:
    - require:
      - git: addon-cert-manager
    - watch:
      - git: addon-cert-manager
    - source: salt://kubernetes/addons/cert-manager/templates/{{ common.addons.cert_manager.dns.provider }}-clusterissuer.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/cert-manager/certificate.yaml:
  file.managed:
    - watch:
      - git: addon-cert-manager
    - source: salt://kubernetes/addons/cert-manager/templates/certificate.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-cert-manager-install:
  cmd.run:
    - watch:
        - git:  addon-cert-manager
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/deploy/manifests/01-namespace.yaml
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/deploy/manifests/00-crds.yaml
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/deploy/manifests/cert-manager.yaml
        kubectl -n cert-manager delete secret public-dns-secret
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
        - file: /srv/kubernetes/manifests/cert-manager/certificate.yaml
    - runas: root
    - use_vt: True
    - onlyif: curl --silent 'http://127.0.0.1:8080/apis/certmanager.k8s.io'
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/clusterissuer.yaml
        kubectl apply -f /srv/kubernetes/manifests/cert-manager/certificate.yaml