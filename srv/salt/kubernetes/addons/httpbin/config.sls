/srv/kubernetes/manifests/httpbin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/httpbin/deployment.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/httpbin
    - source: salt://{{ tpldir }}/templates/deployment.yaml.j2
    - user: root
    - group: root
    - mode: "0644"
    - template: jinja
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/httpbin/service.yaml:
    file.managed:
    - require:
      - file: /srv/kubernetes/manifests/httpbin
    - source: salt://{{ tpldir }}/files/service.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}