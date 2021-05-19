{% from "kubernetes/map.jinja" import charts with context %}

argo-events:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo-events/values.yaml
      - cmd: argo-events-namespace
      - cmd: argo-events-fetch-charts
    - cwd: /srv/kubernetes/manifests/argo-events/argo-events
    - name: |
        kubectl apply -f ./crds/ && \
        helm upgrade --install argo-events --namespace argo-events \
            --values /srv/kubernetes/manifests/argo-events/values.yaml \
            "./" --wait --timeout 5m

argo-events-wait-api:
  cmd.run:
    - name: |
        http --check-status --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/argoproj.io/v1alpha1/ | grep -niE "sensor"
    - use_vt: True
    - retry:
        attempts: 10
        interval: 5

argo-events-webhook-eventsource:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo-events
    - name: /srv/kubernetes/manifests/argo-events/webhook-eventsource.yaml
    - source: salt://{{ tpldir }}/files/webhook-eventsource.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - cmd: argo-events
      - file: /srv/kubernetes/manifests/argo-events/webhook-eventsource.yaml
    - name: |
        kubectl apply -n argo-events -f /srv/kubernetes/manifests/argo-events/webhook-eventsource.yaml

argo-events-eventbus:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo-events
    - name: /srv/kubernetes/manifests/argo-events/eventbus.yaml
    - source: salt://{{ tpldir }}/files/eventbus.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - cmd: argo-events
      - file: /srv/kubernetes/manifests/argo-events/eventbus.yaml
    - name: |
        kubectl apply -n argo-events -f /srv/kubernetes/manifests/argo-events/eventbus.yaml

{%- if charts.get('argo', {'enabled': False}).enabled %}
argo-events-argo-eventbus:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/argo-events
    - name: /srv/kubernetes/manifests/argo-events/argo-eventbus.yaml
    - source: salt://{{ tpldir }}/files/argo-eventbus.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - runas: root
    - watch:
      - cmd: argo-events
      - file: /srv/kubernetes/manifests/argo-events/argo-eventbus.yaml
    - name: |
        kubectl apply -n argo -f /srv/kubernetes/manifests/argo-events/argo-eventbus.yaml
{%- endif %}