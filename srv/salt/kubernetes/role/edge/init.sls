/root/.kube:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/root/.kube/config:
  file.managed:
    - source: salt://kubernetes/role/proxy/templates/kubeconfig.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0640"

/srv/kubernetes:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/srv/kubernetes/acme.json:
  file.managed:
    - source: salt://kubernetes/role/proxy/files/acme.json
    - user: root
    - group: root
    - mode: "0600"
    - replace: False