open-policy-agent-blacklist-images:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/open-policy-agent
    - name: /srv/kubernetes/manifests/open-policy-agent/blacklist-images-template.yaml
    - source: salt://{{ tpldir }}/templates/blacklist-images-template.yaml.j2
    - template: jinja
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/open-policy-agent/blacklist-images-template.yaml
        - cmd: open-policy-agent
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/open-policy-agent/blacklist-images-template.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

open-policy-agent-required-labels:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/open-policy-agent
    - name: /srv/kubernetes/manifests/open-policy-agent/required-labels-template.yaml
    - source: salt://{{ tpldir }}/files/required-labels-template.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/open-policy-agent/required-labels-template.yaml
        - cmd: open-policy-agent
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/open-policy-agent/required-labels-template.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

open-policy-agent-unique-ingress-host:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/open-policy-agent
    - name: /srv/kubernetes/manifests/open-policy-agent/unique-ingress-host-template.yaml
    - source: salt://{{ tpldir }}/files/unique-ingress-host-template.yaml
    - skip_verify: true
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
        - file: /srv/kubernetes/manifests/open-policy-agent/unique-ingress-host-template.yaml
        - cmd: open-policy-agent
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/open-policy-agent/unique-ingress-host-template.yaml
    - onlyif: http --verify false https://localhost:6443/livez?verbose

