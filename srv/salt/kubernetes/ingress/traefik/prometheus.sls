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
    - onlyif: curl --silent 'http://127.0.0.1:8080/healthz/'
    - name: kubectl apply -f /srv/kubernetes/manifests/traefik/service-monitor.yaml