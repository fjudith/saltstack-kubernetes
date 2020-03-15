/srv/kubernetes/manifests/descheduler:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True
    
/srv/kubernetes/manifests/descheduler/configmap.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/descheduler
    - source: salt://{{ tpldir }}/templates/configmap.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/descheduler/cronjob.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/descheduler
    - source: salt://{{ tpldir }}/templates/cronjob.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/descheduler/job.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/descheduler
    - source: salt://{{ tpldir }}/templates/job.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/descheduler/rbac.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/descheduler
    - source: salt://{{ tpldir }}/files/rbac.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}