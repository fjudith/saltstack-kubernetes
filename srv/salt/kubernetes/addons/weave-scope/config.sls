/srv/kubernetes/manifests/weave-scope:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/weave-scope/cluster-role-binding.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/cluster-role-binding.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/cluster-role.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/cluster-role.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/deploy.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/deploy.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/ds.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/ds.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/probe-deploy.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/templates/probe-deploy.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/psp.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/psp.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/sa.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/sa.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/weave-scope/svc.yaml:
    require:
    - file: /srv/kubernetes/manifests/weave-scope
    file.managed:
    - source: salt://{{ tpldir }}/files/svc.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
        tpldir: {{ tpldir }}