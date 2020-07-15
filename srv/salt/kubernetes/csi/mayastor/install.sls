mayastor-mayastornode-crd:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
    - name: /srv/kubernetes/manifests/mayastor/mayastornode-crd.yaml
    - source: salt://{{ tpldir }}/files/mayastornode-crd.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mayastor/mayastornode-crd.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/mayastornode-crd.yaml

mayastor-mayastorpool-crd:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
    - name: /srv/kubernetes/manifests/mayastor/mayastorpool-crd.yaml
    - source: salt://{{ tpldir }}/files/mayastorpool-crd.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mayastor/mayastorpool-crd.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/mayastorpool-crd.yaml

{# mayastor-mayastorvolume-crd:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
    - name: /srv/kubernetes/manifests/mayastor/mayastorvolume-crd.yaml
    - source: salt://{{ tpldir }}/files/mayastorvolume-crd.yaml
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mayastor/mayastorvolume-crd.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/mayastorvolume-crd.yaml #}

mayastor-nats:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
    - name: /srv/kubernetes/manifests/mayastor/nats-deployment.yaml
    - source: salt://{{ tpldir }}/templates/nats-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mayastor/nats-deployment.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/nats-deployment.yaml

mayastor-nats-wait:
  cmd.run:
    - require:
      - cmd: mayastor-nats
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

mayastor-moac:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
    - name: /srv/kubernetes/manifests/mayastor/moac-deployment.yaml
    - source: salt://{{ tpldir }}/templates/moac-deployment.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mayastor/moac-deployment.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/moac-deployment.yaml

mayastor-moac-wait:
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

mayastor:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
      - cmd: openebs-mayastor-nats-wait
      - cmd: openebs-mayastor-moac
    - name: /srv/kubernetes/manifests/mayastor/daemonset.yaml
    - source: salt://{{ tpldir }}/templates/daemonset.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mayastor/daemonset.yaml
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/daemonset.yaml

mayastor-wait:
  cmd.run:
    - require:
      - cmd: mayastor
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

mayastor-pool:
  file.managed:
    - require:
      - file: /srv/kubernetes/manifests/mayastor
    - name: /srv/kubernetes/manifests/mayastor/mayastor-pool.yaml
    - source: salt://{{ tpldir }}/templates/mayastor-pool.yaml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: "0644"
    - context:
      tpldir: {{ tpldir }}
  cmd.run:
    - watch:
      - file: /srv/kubernetes/manifests/mayastor/mayastor-pool.yaml
      - cmd: openebs-mayastor-wait
    - runas: root
    - name: |
        kubectl apply -f /srv/kubernetes/manifests/mayastor/mayastor-pool.yaml