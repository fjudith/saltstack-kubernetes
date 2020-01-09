kubeless:
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/kubeless/kubeless.yaml
        - file: /srv/kubernetes/manifests/kubeless/kubeless-ui.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kubeless.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubeless/kubeless-ui.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'