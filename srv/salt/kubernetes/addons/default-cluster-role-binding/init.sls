{%- from "kubernetes/map.jinja" import common with context -%}

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
    - require:
      - cmd: kubernetes-wait
    - watch:
      - file: /srv/kubernetes/manifests/kube-apiserver-crb.yaml
      - file: /srv/kubernetes/manifests/kubelet-crb.yaml
    - runas: root
    - use_vt: True
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/kube-apiserver-crb.yaml
        kubectl apply -f /srv/kubernetes/manifests/kubelet-crb.yaml