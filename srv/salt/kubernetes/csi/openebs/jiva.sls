openebs-jiva:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/jiva-csi.yaml
    - source: salt://{{ tpldir }}/templates/jiva-csi.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/jiva-csi.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/jiva-csi.yaml