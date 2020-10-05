/srv/kubernetes/manifests/argo:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/argo/workflow-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - source: salt://{{ tpldir }}/templates/workflow-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/workflow-rbac.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - source: salt://{{ tpldir }}/files/workflow-rbac.yaml
    - user: root
    - group: root
    - mode: "0755"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/events-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - source: salt://{{ tpldir }}/templates/events-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/events-argo-rbac.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - source: salt://{{ tpldir }}/files/events-argo-rbac.yaml
    - user: root
    - group: root
    - mode: "0755"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo/cd-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo
    - source: salt://{{ tpldir }}/templates/cd-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
