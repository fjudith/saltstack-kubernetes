{%- from "kubernetes/map.jinja" import common with context -%}

/tmp/kube-proxy-{{ common.version }}:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kube-proxy
    - skip_verify: true
    - group: root
    - mode: 444

kube-proxy-install:
  service.dead:
    - name: kube-proxy.service
    - watch:
      - file: /tmp/kube-proxy-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-proxy /tmp/kube-proxy-{{ common.version }}
  file.copy:
    - name: /usr/local/bin/kube-proxy
    - source: /tmp/kube-proxy-{{ common.version }}
    - mode: 555
    - user: root
    - group: root
    - force: true
    - require:
      - file: /tmp/kube-proxy-{{ common.version }}
    - unless: cmp -s /usr/local/bin/kube-proxy /tmp/kube-proxy-{{ common.version }}

/etc/systemd/system/kube-proxy.service:
  file.managed:
    - source: salt://kubernetes/role/node/kube-proxy/files/kube-proxy.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/var/lib/kube-proxy:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/etc/kubernetes/kube-proxy.kubeconfig:
  file.managed:
    - source: salt://kubernetes/role/node/kube-proxy/templates/kube-proxy.kubeconfig.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/var/lib/kube-proxy/kube-proxy-config.yaml:
  file.managed:
    - source: salt://kubernetes/role/node/kube-proxy/templates/kube-proxy-config.yaml.j2
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kube-proxy.service:
  service.running:
    - watch:
      - file: /etc/systemd/system/kube-proxy.service
      - file: /etc/kubernetes/kube-proxy.kubeconfig
      - file: /var/lib/kube-proxy/kube-proxy-config.yaml
      - file: /usr/local/bin/kube-proxy
    - enable: True

query-kube-proxy:
  http.wait_for_successful_query:
    - name: 'http://127.0.0.1:10249/healthz'
    - match: ok
    - wait_for: 180
    - request_interval: 5
    - status: 200