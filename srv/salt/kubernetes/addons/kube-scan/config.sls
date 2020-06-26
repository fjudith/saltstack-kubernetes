/srv/kubernetes/manifests/kube-scan:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/kube-scan/deployment.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/kube-scan
    - source: salt://{{ tpldir }}/templates/deployment.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}
