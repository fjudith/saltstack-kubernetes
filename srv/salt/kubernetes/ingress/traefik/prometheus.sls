traefik-prometheus-servicemonitor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/traefik
    - name: /srv/kubernetes/manifests/traefik/service-monitor.yaml
    - source: salt://{{ tpldir }}/files/service-monitor.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - cmd: traefik-ingress-namespace
        - file: /srv/kubernetes/manifests/traefik/service-monitor.yaml
    - runas: root
    - onlyif: http --verify false https://localhost:6443/livez?verbose
    - name: kubectl apply -f /srv/kubernetes/manifests/traefik/service-monitor.yaml