jenkins-namespace:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/jenkins
    - name: /srv/kubernetes/manifests/jenkins/namespace.yaml
    - source: salt://{{ tpldir }}/files/namespace.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/jenkins/namespace.yaml
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/jenkins/namespace.yaml
