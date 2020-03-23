falco-remove-charts:
  file.absent:
    - name: /srv/kubernetes/manifests/falco/falco

falco-fetch-charts:
  cmd.run:
    - runas: root
    - require:
      - file: falco-remove-charts
      - file: /srv/kubernetes/manifests/falco
    - cwd: /srv/kubernetes/manifests/falco
    - name: |
        helm fetch --untar stable/falco
