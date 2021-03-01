/srv/kubernetes/manifests/ory:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/ory/hydra-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/hydra-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/ory/hydra-cockroachdb-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/hydra-cockroachdb-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/ory/idp-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/idp-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/ory/kratos-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/kratos-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/ory/kratos-cockroachdb-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/kratos-cockroachdb-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/ory/kratos-selfservice-ui-node-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/kratos-selfservice-ui-node-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/ory/kratos-mailslurper.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/kratos-mailslurper.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/ory/oathkeeper-values.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ory
    - source: salt://{{ tpldir }}/templates/oathkeeper-values.yaml.j2
    - user: root
    - group: root
    - mode: "0755"
    - template: jinja
    - context:
      tpldir: {{ tpldir }}