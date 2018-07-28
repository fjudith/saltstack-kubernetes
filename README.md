<img src="https://i.imgur.com/SJAtDZk.png" width="460" height="125" >

# Work-in-Progress

`saltstack-kubernetes` aims to deploy and maintain a secure production ready **Kubernetes cluster** managed by:

* [Terraform](https://www.terraform.io) for server provionning.
* [Saltstack](https://saltstack.io) for Kubernetes installation and configuration management.

This project is a fusion of the [valentin2105/Kubernetes-Saltstack](https://github.com/valentin2105/Kubernetes-Saltstack) and [hobby-kube](https://github.com/hobby-kube/provisionning) to address the following requirements:

* [x] **Single public IP**
* [x] **Full TLS** communications between cluster components
* [x] Segregated proxy nodes for ingress traffic
* [x] Segregated etcd cluster
* [x] **Proxied and Routed internet access** from Kubernetes servers
* [x] Reverse proxy to kube-apiserver cluster
* [x] **Predictable ip Adressing** using [Wireguard](https://www.wireguard.com) Mesh VPN
* [x] **Automatic certificate provisionning** using terraform
* [x] Fully containerized Kubernetes deployment
  * [x] Use [rkt](https://coreos.com/rkt) for `etcd` and `kubelet` installations.
  * [x] Use [docker](https://www.docker.com) for other kubernetes components (i.e. kube-apiserver, addons, etc.)
* [x] Supports Calico (routed), **Flannel (vxlan) and Canal**.
* [x] API driven DNS registration [Cloudflare](https://cloudflare.com)
* [x] [Node authorization](https://kubernetes.io/docs/reference/access-authn-authz/node/) support
* [x] [Tinyproxy](https://tinyproxy.github.io) for forward proxy
* [x] [HAproxy](https://haproxy.org) for reverse proxy
* [x] [Traefik](https://traefik.io) for Kubernetes Ingress
* [ ] [Suricata](https://suricata-ids.org) for intrusion detection

* Tested cloud providers:
  * [x] [Scaleway](https://www.scaleway.com)


## Features

- Cloud-provider **agnostic**
- Support **high-available** clusters
- Use the power of **`Saltstack`**
- Made for **`SystemD`** based Linux systems
- **Routed** networking by default (**`Calico`**)
- Latest Kubernetes release (**1.10.5**)
- Support **IPv6**
- Integrated **add-ons**
- **Composable** (CNI, CRI)
- **Node Security**, **RBAC** and **TLS** by default

## Getting started 

Clone the repository.

Let's clone the git repo on Salt-Master and create CA & Certificates on the `certs/` directory using **`CfSSL`** tools:

```bash
git clone https://github.com/fjudith/saltstack-kubernetes
ln -s saltstack-kubernetes/salt /srv/salt
ln -s saltstack-kubernetes/pillar /srv/pillar

sudo curl -fsSL -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
sudo curl -fsSL -o /usr/local/bin/cfssl-certinfo https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
sudo curl -fsSL -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

sudo chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson /usr/local/bin/cfssl-certinfo
```

### IMPORTANT Point

Because we need to generate our own CA and Certificates for the cluster, You MUST put **every hostnames of the Kubernetes cluster** (Master & nodes) in the `certs/kubernetes-csr.json` (`hosts` field). You can also modify the `certs/*json` files to match your cluster-name / country. (optional)  

You can use either public or private names, but they must be registered somewhere (DNS provider, internal DNS server, `/etc/hosts` file).

```bash
cd /srv/salt/certs
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Don't forget to edit kubernetes-csr.json before this point !

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
```
After that, edit the `pillar/cluster_config.sls` to configure your future Kubernetes cluster :

```bash
# Generate encryption key 
echo $(head -c 32 /dev/urandom | base64)

# Generate tokens
echo $(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
```

```yaml
public-domain: example.com
kubernetes:
  common:
    image: quay.io/fjudith/hyperkube:v1.10.5
    version: v1.10.5
    addons:
      dns:
        enabled: True
        domain: cluster.local
        server: 10.3.0.10
        autoscaler:
          enabled: True
        coredns:
          enabled: True
      helm:
        enabled: False
        tiller_image: gcr.io/kubernetes-helm/tiller:v2.4.2
      kube-prometheus:
        enabled: True
        version: v0.22.0
      heapster-influxdb:
        enabled: True
      dashboard:
        enabled: True
      ingress_traefik:
        enabled: True
        password: '$apr1$mHqffeCI$8Bl8/cCsjejRsAYt7qFrj/'
        acme_email: user.name@example.com
      npd:
        enabled: True
      ingress-nginx:
        enabled: False
      fluentd-elasticsearch:
        enabled: True
  etcd:
    host: 127.0.0.1
    members:
      - host: 172.17.4.51
        name: etcd01
      - host: 172.17.4.52
        name: etcd02
      - host: 172.17.4.53
        name: etcd03
    version: v3.1.12
  master:
    service_addresses: 10.3.0.0/24
    members:
      - host: 172.17.4.101
        name: master01
      - host: 172.17.4.102
        name: master02
      - host: 172.17.4.103
        name: master03
    encryption-key: 'ScKZBwy8IYi8vpUnJNXkQF/ODsGWJX22+nc8WGFzZgw=' 
    token:
      admin: 227c24c3e683a4ea584f95580023387e
      kubelet: 3e749c1636005866f497ec5877d103df
      calico: 07519ca856c5a8742e23d5f7c4bed7f2
      kube_scheduler: bbfd644a90a5fb95827f5b3091c80efc
      kube_controller_manager: f1ab133b52ea3501e6d744656d22a1ae
      kube_proxy: 5f5b9898b76a8cebbc7114a0fdc31883
      bootstrap: 92a007b80db4b2b85cd60270f822a3b9
      monitoring: 617b5a516e217054391940f158f7221d
      logging: c377a4832fc3cc914a18cd7324c2549f
      dns: cb49512c71db4e60d5c7373c21e07504
    storage:
      rook:
        enabled: True
  node:
    runtime:
      provider: docker
      docker:
        version: 17.03.2-ce
        data-dir: /var/lib/docker
      rkt:
        version: 1.29.0
    networking:
      cni-version: v0.7.1
      provider: flannel
      calico:
        version: v3.1.3
        cni-version: v3.1.3
        calicoctl-version: v3.1.3
        controller-version: 3.1-release
        as-number: 64512
        token: 7d8d28fe2500143b09cfceea3b48f00e
        ipv4:
          range: 10.2.0.0/16
          nat: true
          ip-in-ip: true
        ipv6:
          enable: false
          nat: true
          interface: eth0
          range: fd80:24e2:f998:72d6::/64
      flannel:
        version: v0.10.0-amd64
        ipv4:
          range: 10.2.0.0/16
          interface: eth0
  global:
    proxy:
      ipaddr: 172.16.4.251
      port: 8888
    vpnIP-range: 172.16.4.0/24
    pod-network: 10.2.0.0/16
    kubernetes-service-ip: 10.3.0.1
    service-ip-range: 10.3.0.0/24
    cluster-dns: 10.3.0.10
    helm-version: v2.8.2
    dashboard-version: v1.8.3
tinyproxy:
  MaxClients: 200
  MinSpareServers: 10
  MaxSpareServers: 40
  StartServers: 20
  Allow:
    - 127.0.0.1
    - 192.168.0.0/16
    - 172.16.0.0/12
    - 10.0.0.0/8
  ConnectPort:
    - 443
    - 563
    - 6443
    - 2379
    - 2380
keepalived:
  global_defs:
    router_id: LVS_DEVEL
  vrrp_instance:
    VI_1:
      state: MASTER
      interface: wg0
      virtual_router_id: 51
      priority: 100
      advert_int: 1
      authentication:
        auth_type: PASS
        auth_pass: 1111
      virtual_ipaddress:
        - 172.16.4.253
        - 172.16.4.254
  virtual_server:
    0.0.0.0 6443:
      delay_loop: 6
      lb_algo: rr
      lb_kind: NAT
      nat_mask: 255.255.255.0
      persistence_timeout: 50
      protocol: TCP
      real_server:
        172.17.4.101 6443:
          weight: 1
        172.17.4.102 6443:
          weight: 2
        172.17.4.103 6443:
          weight: 3
haproxy:
  enabled: true
  overwrite: True
  defaults:
    timeouts:
      - tunnel        3600s
      - http-request    10s
      - queue           1m
      - connect         10s
      - client          1m
      - server          1m
      - http-keep-alive 10s
      - check 10s
    stats:
      - enable
      - uri: 'admin?stats'
  listens:
    stats:
      bind:
        - "0.0.0.0:18080"
      mode: http
      stats:
        enable: True
        uri: "/admin?stats"
  global:
    ssl-default-bind-ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384"
    ssl-default-bind-options: "no-sslv3 no-tlsv10 no-tlsv11"
  user: haproxy
  group: haproxy
  chroot:
    enable: true
    path: /var/lib/haproxy
  daemon: true
  frontends:
    kubernetes-master:
      bind: "*:6443"
      mode: tcp
      default_backend: kube-apiserver
  backends:
    kube-apiserver:
      mode: tcp
      balance: source
      sticktable: "type binary len 32 size 30k expire 30m"
      servers:
        master01:
          host: 172.17.4.101
          port: 6443
          check: check
        master02:
          host: 172.17.4.102
          port: 6443
          check: check
        master03:
          host: 172.17.4.103
          port: 6443
          check: check
```
##### Don't forget to change hostnames & tokens  using command like `pwgen 64` !

If you want to enable IPv6 on pod's side, you need to change `kubernetes.node.networking.calico.ipv6.enable` to `true`.

## Deployment

To deploy your Kubernetes cluster using this formula, you first need to setup your Saltstack Master/Minion.  
You can use [Salt-Bootstrap](https://docs.saltstack.com/en/stage/topics/tutorials/salt_bootstrap.html) or [Salt-Cloud](https://docs.saltstack.com/en/latest/topics/cloud/) to enhance the process. 

The configuration is done to use the Salt-Master as the Kubernetes Master. You can have them as different nodes if needed but the `post_install/script.sh` require `kubectl` and access to the `pillar` files.

#### The recommended configuration is :

- One or two proxy servers

- One or three Etcd servers

- One or three Kubernetes Master (Salt-Master & Minion)

- One or more Kubernetes Nodes (Salt-minion)

The Minion's roles are matched with `Salt Grains` (kind of inventory), so you need to define theses grains on your servers :

If you want a small cluster, a Master can be a node too. 

```bash
# Kubernetes Masters
cat << EOF > /etc/salt/grains
role: master
EOF

# Kubernetes nodes
cat << EOF > /etc/salt/grains
role: node
EOF

# Kubernetes Master & nodes
cat << EOF > /etc/salt/grains
role: 
  - master
  - node
EOF

service salt-minion restart 
```

After that, you can apply your configuration (`highstate`) :

```bash
# Apply Kubernetes Master configurations
salt -G 'role:master' state.highstate 

~# kubectl get componentstatuses
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
etcd-2               Healthy   {"health": "true"}

# Apply Kubernetes node configurations
salt -G 'role:node' state.highstate

~# kubectl get nodes
NAME                STATUS    ROLES     AGE       VERSION   EXTERNAL-IP   OS-IMAGE 
k8s-salt-node01   Ready     <none>     5m       v1.10.1    <none>        Ubuntu 18.04.1 LTS 
k8s-salt-node02   Ready     <none>     5m       v1.10.1    <none>        Ubuntu 18.04.1 LTS 
k8s-salt-node03   Ready     <none>     5m       v1.10.1    <none>        Ubuntu 18.04.1 LTS 
k8s-salt-node04   Ready     <none>     5m       v1.10.1    <none>        Ubuntu 18.04.1 LTS 
```

To enable add-ons on the Kubernetes cluster, you can launch the `post_install/setup.sh` script :

```bash
/srv/salt/post_install/setup.sh

~# kubectl get pod --all-namespaces
NAMESPACE     NAME                                    READY     STATUS    RESTARTS   AGE
kube-system   calico-policy-fcc5cb8ff-tfm7v           1/1       Running   0          1m
kube-system   calico-node-bntsh                       1/1       Running   0          1m
kube-system   calico-node-fbicr                       1/1       Running   0          1m
kube-system   calico-node-badop                       1/1       Running   0          1m
kube-system   calico-node-rcrze                       1/1       Running   0          1m
kube-system   kube-dns-d44664bbd-596tr                3/3       Running   0          1m
kube-system   kube-dns-d44664bbd-h8h6m                3/3       Running   0          1m
kube-system   kubernetes-dashboard-7c5d596d8c-4zmt4   1/1       Running   0          1m
kube-system   tiller-deploy-546cf9696c-hjdbm          1/1       Running   0          1m
kube-system   heapster-55c5d9c56b-7drzs               1/1       Running   0          1m
kube-system   monitoring-grafana-5bccc9f786-f4lf2     1/1       Running   0          1m
kube-system   monitoring-influxdb-85cb4985d4-rd776    1/1       Running   0          1m
```

## Good to know

If you want to add a node on your Kubernetes cluster, just add the new **Hostname** on `kubernetes-csr.json` and run theses commands :

```bash
cd /srv/salt/certs

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

salt -G 'role:master' state.highstate
salt -G 'role:node' state.highstate
```

Last `highstate` reload your Kubernetes Master and configure automaticly new nodes.

- Tested on Debian, Ubuntu and Fedora.
- You can easily upgrade software version on your cluster by changing values in `pillar/cluster_config.sls` and apply a `state.highstate`.
- This configuration use ECDSA certificates (you can switch to `rsa` if needed in `certs/*.json`).
- You can tweak Pod's IPv4 Pool, enable IPv6, change IPv6 Pool, enable IPv6 NAT (for no-public networks), change BGP AS number, Enable IPinIP (to allow routes sharing of different cloud providers).
- If you use `salt-ssh` or `salt-cloud` you can quickly scale new nodes.


## Support on Beerpay
Hey dude! Help me out for a couple of :beers:!

[![Beerpay](https://beerpay.io/valentin2105/Kubernetes-Saltstack/badge.svg?style=beer-square)](https://beerpay.io/valentin2105/Kubernetes-Saltstack)  [![Beerpay](https://beerpay.io/valentin2105/Kubernetes-Saltstack/make-wish.svg?style=flat-square)](https://beerpay.io/valentin2105/Kubernetes-Saltstack?focus=wish)
