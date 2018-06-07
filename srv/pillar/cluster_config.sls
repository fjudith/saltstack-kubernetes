kubernetes:
  version: v1.10.4
  domain: cluster.local
  clusterDNS: 10.32.0.10
  etcd:
    count: 3
    cluster:
      etcd01:
        hostname: etcd01
        ipaddr: 172.16.4.51
      etcd02:
        hostname: etcd02
        ipaddr: 172.16.4.52
      etcd03:
        hostname: etcd03
        ipaddr: 172.16.4.53
    version: v3.2.22
  master:
#    count: 1
#    hostname: master.domain.tld
#    ipaddr: 10.240.0.10
    count: 3
    cluster:
      node01:
        hostname: master01.domain.tld
        ipaddr: 172.16.4.101
      node02:
        hostname: master02.domain.tld
        ipaddr: 172.16.4.102
      node03:
        hostname: master03.domain.tld
        ipaddr: 172.16.4.103
    encryption-key: 'w3RNESCMG+o3GCHTUcrQUUdq6CFV72q/Zik9LAO8uEc='
  node:
    runtime:
      provider: docker
      docker:
        version: 17.03.2-ce
        data-dir: /var/lib/docker
    networking:
      cni-version: v0.7.1
      provider: calico
      calico:
        version: v3.1.3
        cni-version: v3.1.3
        calicoctl-version: v3.1.3
        controller-version: 3.1-release
        as-number: 64512
        token: hu0daeHais3aCHANGEMEhu0daeHais3a
        ipv4:
          range: 192.168.0.0/16
          nat: true
          ip-in-ip: true
        ipv6:
          enable: false
          nat: true
          interface: ens18
          range: fd80:24e2:f998:72d6::/64
  global:
    proxy:
      ipaddr: 172.16.4.251
      port: 8888
    vpnIP-range: 172.16.4.0/24
    clusterIP-range: 10.96.0.0/16
    helm-version: v2.8.2
    dashboard-version: v1.8.3
    admin-token: Haim8kay1rarCHANGEMEHaim8kay1rar
    kubelet-token: ahT1eipae1wiCHANGEMEahT1eipae1wi  
