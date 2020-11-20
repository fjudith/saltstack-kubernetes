jenkins-ingress:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/jenkins
    - name: /srv/kubernetes/manifests/jenkins/jenkins-ingress.yaml
    - source: salt://{{ tpldir }}/templates/ingress.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - require:
      - cmd: jenkins
    - watch:
      - file: /srv/kubernetes/manifests/jenkins/jenkins-ingress.yaml
    - runas: root
    - name: kubectl apply -f /srv/kubernetes/manifests/jenkins/jenkins-ingress.yaml
