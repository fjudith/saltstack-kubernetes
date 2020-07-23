argo-events:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/events-deployment.yaml
    - source: salt://{{ tpldir }}/templates/events-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - cmd: argo-events-namespace
      - file: /srv/kubernetes/manifests/argo/events-deployment.yaml
    - name: |
        kubectl apply -n argo-events -f /srv/kubernetes/manifests/argo/events-deployment.yaml

argo-events-wait-api:
  http.wait_for_successful_query:
    - name: 'http://localhost:8080/apis/argoproj.io/v1alpha1/'
    - match: Sensor
    - wait_for: 60
    - request_interval: 5
    - status: 200

# RBAC allowing Argo-Events to publish workflow in the  `argo` namespace
argo-events-argo-rbac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/events-argo-rbac.yaml
    - source: salt://{{ tpldir }}/files/events-argo-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - cmd: argo-events
      - file: /srv/kubernetes/manifests/argo/events-argo-rbac.yaml
    - name: |
        kubectl apply -n argo-events -f /srv/kubernetes/manifests/argo/events-argo-rbac.yaml

argo-events-webhook-gateway:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/events-argo-rbac.yaml
    - source: salt://{{ tpldir }}/files/events-argo-rbac.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - cmd: argo-events
      - file: /srv/kubernetes/manifests/argo/events-webhook-gateway.yaml
    - name: |
        kubectl apply -n argo-events -f /srv/kubernetes/manifests/argo/events-webhook-gateway.yaml

argo-events-webhook-eventsource:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo
    - name: /srv/kubernetes/manifests/argo/events-webhook-eventsource.yaml
    - source: salt://{{ tpldir }}/files/events-webhook-eventsource.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - cmd: argo-events
      - file: /srv/kubernetes/manifests/argo/events-webhook-eventsource.yaml
    - name: |
        kubectl apply -n argo-events -f /srv/kubernetes/manifests/argo/events-webhook-eventsource.yaml