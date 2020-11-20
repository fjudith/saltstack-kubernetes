jenkins-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/jenkins/jenkins

jenkins-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: jenkins-remove-charts
      - file: /srv/kubernetes/manifests/jenkins
    - cwd: /srv/kubernetes/manifests/jenkins
    - name: |
        helm repo add jenkinsci https://charts.jenkins.io
        helm fetch --untar jenkinsci/jenkins