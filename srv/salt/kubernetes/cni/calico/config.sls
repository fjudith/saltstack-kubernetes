/srv/kubernetes/manifests/calico:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/etc/calico/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/etc/calico/kube/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/opt/calico/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/opt/calico/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"

/srv/kubernetes/manifests/calico/calico-rbac-kkd.yaml:
    file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/calico
    - source: salt://{{ tpldir }}/files/calico-rbac-kkd.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/calico/calico-typha.yaml:
    file.managed:
    - watch:
      - file: /srv/kubernetes/manifests/calico
    - source: salt://{{ tpldir }}/templates/calico-typha.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
