argo-events:
  cmd.run:
    - runas: root
    - watch:
      - file: /srv/kubernetes/manifests/argo-events/values.yaml
      - file: /srv/kubernetes/manifests/argo-events/argo-rbac.yaml
      - cmd: argo-events-namespace
      - cmd: argo-events-fetch-charts
    - cwd: /srv/kubernetes/manifests/argo-events/argo-events
    - name: |
        # RBAC allowing Argo-Events to publish workflow in the  `argo` namespace
        kubectl apply -n argo -f /srv/kubernetes/manifests/argo-events/argo-rbac.yaml
        
        kubectl apply -f ./crds/ && \
        helm upgrade --install argo-events --namespace argo-events \
            --values /srv/kubernetes/manifests/argo-events/values.yaml \
            "./" --wait --timeout 5m

argo-events-wait-api:
  cmd.run:
    - name: |
        http --verify false \
          --cert /etc/kubernetes/pki/apiserver-kubelet-client.crt \
          --cert-key /etc/kubernetes/pki/apiserver-kubelet-client.key \
          https://localhost:6443/apis/argoproj.io/v1alpha1/ | grep -niE "sensor"
    - use_vt: True
    - retry:
        attempts: 60
        until: True
        interval: 5
        splay: 10

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
