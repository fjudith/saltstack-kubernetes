/srv/kubernetes/manifests/open-policy-agent:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/open-policy-agent/gatekeeper.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/open-policy-agent
    - source: salt://{{ tpldir }}/templates/gatekeeper.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}