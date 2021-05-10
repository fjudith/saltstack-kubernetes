/srv/kubernetes/manifests/tekton:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/tekton/release.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/tekton
    - source: salt://{{ tpldir }}/templates/release.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/tekton/operator_v1alpha1_dashboard_cr.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/tekton
    - source: salt://{{ tpldir }}/files/operator_v1alpha1_dashboard_cr.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/tekton/operator_v1alpha1_pipeline_cr.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/tekton
    - source: salt://{{ tpldir }}/files/operator_v1alpha1_pipeline_cr.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/tekton/operator_v1alpha1_trigger_cr.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/tekton
    - source: salt://{{ tpldir }}/files/operator_v1alpha1_trigger_cr.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
