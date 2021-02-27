contour-clusterrole-patch:
  file.managed:
    - name: /srv/kubernetes/manifests/contour/clusterrole.yaml
    - source: salt://{{ tpldir }}/patch/clusterrole.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/contour/clusterrole.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/contour/clusterrole.yaml