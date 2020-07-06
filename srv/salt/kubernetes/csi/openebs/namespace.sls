{%- from "kubernetes/map.jinja" import storage with context -%}

{%- if storage.openebs.get('mayastor', {'enabled': False}).enabled %}
openebs-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/openebs-namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/openebs/openebs-namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/openebs-namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
{%- else %}
mayastor-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/mayastor-namespace.yaml
    - source: salt://{{ tpldir }}/files/mayastor-namespace.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/openebs/mayastor-namespace.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/mayastor-namespace.yaml
    - onlyif: curl --silent 'http://127.0.0.1:8080/version/'
{%- endif %}
