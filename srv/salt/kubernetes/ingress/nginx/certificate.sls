/srv/kubernetes/manifests/nginx/certificate.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://{{ tpldir }}/templates/certificate.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

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