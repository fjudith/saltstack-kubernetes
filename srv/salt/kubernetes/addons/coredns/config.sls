/srv/kubernetes/manifests/coredns:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/coredns/deployment.yaml:
    file.managed:
    - source: salt://{{ tpldir }}/templates/deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}