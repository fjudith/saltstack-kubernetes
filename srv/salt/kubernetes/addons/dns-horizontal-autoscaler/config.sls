/srv/kubernetes/manifests/dha-rbac.yaml:
  file.managed:
    - source: salt://{{ tpldir }}/files/dha-rbac.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/dha-deployment.yaml:
  file.managed:
    - source: salt://{{ tpldir }}/files/dha-deployment.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}