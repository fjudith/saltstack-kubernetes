openebs-blockdevice:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/ndm-blockdevice.yaml
    - source: salt://{{ tpldir }}/templates/ndm-blockdevice.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/ndm-blockdevice.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/ndm-blockdevice.yaml