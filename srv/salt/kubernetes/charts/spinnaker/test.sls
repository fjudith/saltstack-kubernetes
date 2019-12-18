{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

query-spinnaker-deck:
  http.wait_for_successful_query:
    - watch:
      - cmd: spinnaker-ingress
    - name: https://{{ charts.spinnaker.ingress_host }}.{{ public_domain }}
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-spinnaker-gate:
  http.wait_for_successful_query:
    - watch:
      - cmd: spinnaker-ingress
    - name: https://{{ charts.spinnaker.ingress_host }}-gate.{{ public_domain }}
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 200

query-spinnaker-minio:
  http.wait_for_successful_query:
    - watch:
      - cmd: spinnaker-ingress
    - name: https://{{ charts.spinnaker.ingress_host }}-minio.{{ public_domain }}
    # - match: DaemonSet
    - wait_for: 120
    - request_interval: 5
    - status: 200

spinnaker-front50-wait:
  cmd.run:
    - require:
      - cmd: spinnaker
    - runas: root
    - name: | 
        until kubectl -n spinnaker get pods --selector=cluster=spin-front50 --field-selector=status.phase=Running 
        do 
          printf 'spin-front50 is not Running' && sleep 5
        done
    - use_vt: True
    - timeout: 600