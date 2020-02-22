/srv/kubernetes/manifests/coredns.yaml:
    file.managed:
    - source: salt://{{ tpldir }}/templates/deployment.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}