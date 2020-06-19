/srv/kubernetes/manifests/argo:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/argo/argo-cd.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - source: salt://{{ tpldir }}/templates/argo-cd.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/argo-workflow.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - source: salt://{{ tpldir }}/templates/argo-workflow.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}