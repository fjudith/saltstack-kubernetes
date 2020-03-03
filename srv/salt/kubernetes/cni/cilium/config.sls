/srv/kubernetes/manifests/cilium:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/cilium/cilium.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/cilium
    - source: salt://{{ tpldir }}/templates/cilium.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - context:
      tpldir: {{ tpldir }}