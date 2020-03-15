/srv/kubernetes/manifests:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/kube-apiserver-crb.yaml:
  file.managed:
    - source: salt://{{ tpldir }}/files/kube-apiserver-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/kubelet-crb.yaml:
  file.managed:
    - source: salt://{{ tpldir }}/files/kubelet-crb.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}