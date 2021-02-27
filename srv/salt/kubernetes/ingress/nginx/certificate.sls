/srv/kubernetes/manifests/nginx/certificate.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://{{ tpldir }}/templates/certificate.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

nginx-ingress-cert-manager-api:
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/cert-manager.io
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

nginx-ingress-certificate:
  cmd.run:
    - require:
      - cmd: nginx-ingress-cert-manager-api
      - cmd: nginx-ingress-install
    - watch:
      - file: /srv/kubernetes/manifests/nginx/certificate.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/nginx/certificate.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose