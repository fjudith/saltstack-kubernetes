/srv/kubernetes/manifests/traefik:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/traefik/traefik.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik
    file.managed:
    - source: salt://{{ tpldir }}/templates/traefik.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/traefik/service-monitor.yaml:
    require:
    - file: /srv/kubernetes/manifests/traefik
    file.managed:
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}