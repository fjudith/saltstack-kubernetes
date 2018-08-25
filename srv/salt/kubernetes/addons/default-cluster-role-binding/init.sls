{%- from "kubernetes/map.jinja" import common with context -%}

/srv/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/kube-apiserver-crb.yaml:
    file.managed:
    - source: salt://kubernetes/addons/default-cluster-role-binding/kube-apiserver-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/srv/kubernetes/manifests/kubelet-crb.yaml:
    file.managed:
    - source: salt://kubernetes/addons/default-cluster-role-binding/kubelet-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubernetes-role-install:
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/kube-apiserver-crb.yaml
      - file: /srv/kubernetes/manifests/kubelet-crb.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-apiserver-crb.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubelet-crb.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'