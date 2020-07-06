openebs-mayastornode-crd:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/mayastornode-crd.yaml
    - source: salt://{{ tpldir }}/files/mayastornode-crd.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/mayastornode-crd.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/mayastornode-crd.yaml

openebs-mayastorpool-crd:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/mayastorpool-crd.yaml
    - source: salt://{{ tpldir }}/files/mayastorpool-crd.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/mayastorpool-crd.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/mayastorpool-crd.yaml

{# openebs-mayastorvolume-crd:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/mayastorvolume-crd.yaml
    - source: salt://{{ tpldir }}/files/mayastorvolume-crd.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/mayastorvolume-crd.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/mayastorvolume-crd.yaml #}

openebs-mayastor-nats:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/nats-deployment.yaml
    - source: salt://{{ tpldir }}/templates/nats-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/nats-deployment.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/nats-deployment.yaml

openebs-mayastor-nats-wait:
  cmd.run:
    - require:
      - cmd: openebs-mayastor-nats
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n mayastor get deployment nats; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n mayastor get deployment nats -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for nats to be up and running" && \
        
        while [ "$(kubectl -n mayastor get deployment nats -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n mayastor get deployment nats  

openebs-mayastor-moac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/moac-deployment.yaml
    - source: salt://{{ tpldir }}/templates/moac-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/moac-deployment.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/moac-deployment.yaml

openebs-mayastor-moac-wait:
  cmd.run:
    - require:
      - cmd: openebs-mayastor-moac
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n mayastor get deployment moac; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n mayastor get deployment moac -o jsonpath='{.status.replicas}') && \
        
        echo "Waiting for moac to be up and running" && \
        
        while [ "$(kubectl -n mayastor get deployment moac -o jsonpath='{.status.readyReplicas}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n mayastor get deployment moac  

openebs-mayastor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/openebs
      - cmd: openebs-mayastor-nats-wait
      - cmd: openebs-mayastor-moac
    - name: /srv/kubernetes/manifests/openebs/mayastor-daemonset.yaml
    - source: salt://{{ tpldir }}/templates/mayastor-daemonset.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/mayastor-daemonset.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/mayastor-daemonset.yaml

openebs-mayastor-wait:
  cmd.run:
    - require:
      - cmd: openebs
    - runas: root
    - timeout: 180
    - name: |
        until kubectl -n mayastor get daemonset mayastor; do printf '.' && sleep 5 ; done
        echo "" && \

        REPLICAS=$(kubectl -n mayastor get daemonset mayastor -o jsonpath='{.status.desiredNumberScheduled}') && \
        
        echo "Waiting for mayastor to be up and running" && \
        
        while [ "$(kubectl -n mayastor get daemonset mayastor -o jsonpath='{.status.numberReady}')" != "${REPLICAS}" ]
        do
          printf '.' && sleep 5
        done && \
        echo "" && \

        kubectl -n mayastor get daemonset mayastor

openebs-mayastor-pool:
  file.managed:
    - require:
      - cmd: openebs-mayastor-wait
      - file: /srv/kubernetes/manifests/openebs
    - name: /srv/kubernetes/manifests/openebs/pool.yaml
    - source: salt://{{ tpldir }}/files/pool.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/openebs/pool.yaml
      - cmd: openebs-mayastor-wait
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/openebs/pool.yaml