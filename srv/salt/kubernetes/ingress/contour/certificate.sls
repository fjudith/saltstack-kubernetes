contour-cert-manager-wait-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/cert-manager.io | grep -niE "cert-manager.io"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

contour-certificate:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/contour
    - name: /srv/kubernetes/manifests/contour/certificate.yaml
    - source: salt://{{ tpldir }}/templates/certificate.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: contour-cert-manager-wait-api
    - watch:
      - file: /srv/kubernetes/manifests/contour/certificate.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/contour/certificate.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose
