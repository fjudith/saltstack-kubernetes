argo-events-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/argo-events/argo-events

argo-events-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: argo-events-remove-charts
      - file: /srv/kubernetes/manifests/argo-events
    - cwd: /srv/kubernetes/manifests/argo-events
    - name: |
        helm repo add argo https://argoproj.github.io/argo-helm
        helm fetch --untar argo/argo-events

/srv/kubernetes/manifests/argo-events/argo-events/crds/eventbus-crd.yml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo-events
    - source: salt://{{ tpldir }}/patch/eventbus-crd.yml
    - user: root
    - group: root
    - mode: "0755"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo-events/argo-events/crds/eventsource-crd.yml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo-events
    - source: salt://{{ tpldir }}/patch/eventsource-crd.yml
    - user: root
    - group: root
    - mode: "0755"
    - context:
      tpldir: {{ tpldir }}

/srv/kubernetes/manifests/argo-events/argo-events/crds/sensor-crd.yml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/argo-events
    - source: salt://{{ tpldir }}/patch/sensor-crd.yml
    - user: root
    - group: root
    - mode: "0755"
    - context:
      tpldir: {{ tpldir }}