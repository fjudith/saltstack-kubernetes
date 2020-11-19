/srv/kubernetes/manifests/contour/certificate.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/contour
    - source: salt://{{ tpldir }}/templates/certificate.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

contour-cert-manager-required-api:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:8080/apis/cert-manager.io'
    - match: cert-manager.io
    - wait_for: 180
    - request_interval: 5
    - status: 200

contour-certificate:
  cmd.run:
    - require:
      - http: contour-cert-manager-required-api
      - cmd: contour-install
    - watch:
      - file: /srv/kubernetes/manifests/contour/certificate.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/contour/certificate.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz'