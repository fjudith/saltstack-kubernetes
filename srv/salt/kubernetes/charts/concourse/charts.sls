concourse-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/concourse/concourse

concourse-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: concourse-remove-charts
      - file: /srv/kubernetes/manifests/concourse
    - cwd: /srv/kubernetes/manifests/concourse
    - name: |
        helm repo add concourse https://concourse-charts.storage.googleapis.com/
        helm fetch --untar concourse/concourse
  file.absent:
    - name: /srv/kubernetes/manifests/concourse/concourse/requirements.lock

/srv/kubernetes/manifests/concourse/concourse/requirements.yaml:
  file.managed:
    - watch:
      - cmd: concourse-fetch-charts
    - source: salt://{{ tpldir }}/patch/requirements.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}