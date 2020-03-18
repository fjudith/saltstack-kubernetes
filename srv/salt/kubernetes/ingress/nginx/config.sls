/srv/kubernetes/manifests/nginx:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0750"
    - makedirs: True

/srv/kubernetes/manifests/nginx/values.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://{{ tpldir }}/templates/values.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nginx/configuration.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://{{ tpldir }}/files/configuration.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
        tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nginx/prometheus.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://{{ tpldir }}/files/prometheus.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/nginx/grafana.yaml:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/nginx
    - source: salt://{{ tpldir }}/files/grafana.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}