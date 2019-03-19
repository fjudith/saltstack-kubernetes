{%- set public_domain = pillar['public-domain'] -%}
{%- from "kubernetes/map.jinja" import charts with context -%}

/srv/kubernetes/manifests/ethereum:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750
    - makedirs: True

/srv/kubernetes/manifests/ethereum/ethereum-ingress.yaml:
  file.managed:
    - require:
      - file:  /srv/kubernetes/manifests/ethereum
    - source: salt://kubernetes/charts/ethereum/templates/ingress.yaml.jinja
    - user: root
    - template: jinja
    - group: root
    - mode: 644

ethereum:
  cmd.run:
    - runas: root
    - unless: helm list | grep ethereum
    - env:
      - HELM_HOME: /srv/helm/home
    - name: |
        helm install --name ethereum --namespace ethereum \
            --set geth.account.address="{{ charts.ethereum.address }}" \
            --set geth.account.privateKey="{{ charts.ethereum.private_key }}" \
            --set geth.account.secret="{{ charts.ethereum.secret }}" \
            --set bootnode.image.tag=alltools-v{{ charts.ethereum.version }} \
            --set ethstats.image.repository=machete3000/etc-netstats \
            --set ethstats.image.tag=latest \
            --set geth.image.tag=v{{ charts.ethereum.version }} \
            "stable/ethereum"
  
ethereum-ingress:
    cmd.run:
      - require:
        - cmd: ethereum
      - watch:
        - file: /srv/kubernetes/manifests/ethereum-ingress.yaml
      - runas: root
      - name: kubectl apply -f /srv/kubernetes/manifests/ethereum-ingress.yaml