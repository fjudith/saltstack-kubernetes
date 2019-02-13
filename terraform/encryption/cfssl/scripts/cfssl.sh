#!/usr/bin/env bash
set -e

# define location of openssl binary manually since running this
# script under Vagrant fails on some systems without it
if ! which cfssl cfssl-certinfo cfssljson > /dev/null ; then
    case $(uname -s) in
      "Linux")
        curl -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
        curl -o /usr/local/bin/cfssl-certinfo https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
        curl -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
        chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson /usr/local/bin/cfssl-certinfo
        ;;
      "Darwin")
        curl -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_darwin-amd64
        curl -o /usr/local/bin/cfssl-certinfo https://pkg.cfssl.org/R1.2/cfssl-certinfo_darwin-amd64
        curl -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_darwin-amd64
        chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson /usr/local/bin/cfssl-certinfo
        ;;
      "MINGW*")
        curl -o /usr/bin/cfssl.exe https://pkg.cfssl.org/R1.2/cfssl_windows-amd64.exe && \
        curl -o /usr/bin/cfssl-certinfo.exe https://pkg.cfssl.org/R1.2/cfssl-certinfo_windows-amd64.exe && \
        curl -o /usr/bin/cfssljson.exe https://pkg.cfssl.org/R1.2/cfssljson_windows-amd64.exe
        ;;
    esac
fi

function usage {
    echo "USAGE: $0 <output-dir> <cert-base-name> <CN> [SAN,SAN,SAN]"
    echo "  example: $0 ./ssl/ worker kube-worker IP.1=127.0.0.1,IP.2=10.0.0.1"
}

# Check Mandatory 
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    usage
    exit 1
fi

OUTDIR="$1"
CERTBASE="$2"
CN="$3"
SANS="$4"


mkdir -p $OUTDIR

if [ ! -d $OUTDIR ]; then
    echo "ERROR: output directory does not exist:  $OUTDIR"
    exit 1
fi

OUTFILE="$OUTDIR/$CN.tar"

if [ -f "$OUTFILE" ];then
    exit 0
fi

# Root CA certificate
# ---------------------------------------------
function write-ssl-ca {
    # Write cfssl JSON template for signing configuration
    local TEMPLATE=$OUTDIR/ca-config.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "signing": {
    "default": {
      "expiry": "12000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "12000h"
      }
    }
  }
}
EOF

    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/ca-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "kubernetes",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/ca.pem"
    CAKEYFILE="$OUTDIR/ca-key.pem"
    CACONFIG=$OUTDIR/ca-config.json

    cfssl gencert -initca $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/ca
}

# Etcd Root CA certificate
# ---------------------------------------------
function write-ssl-etcd-ca {
    # Write cfssl JSON template for signing configuration
    local TEMPLATE=$OUTDIR/etcd-ca-config.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "signing": {
    "default": {
      "expiry": "12000h"
    },
    "profiles": {
      "etcd": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "12000h"
      }
    }
  }
}
EOF

    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/etcd-ca-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "etcd-ca",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Etcd cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/etcd-ca.pem"
    CAKEYFILE="$OUTDIR/etcd-ca-key.pem"
    CACONFIG=$OUTDIR/etcd-ca-config.json

    cfssl gencert -initca $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/etcd-ca
}

# Kube-Aggregator Root CA certificate
# ---------------------------------------------
function write-ssl-kube-aggregator-ca {
    # Write cfssl JSON template for signing configuration
    local TEMPLATE=$OUTDIR/kube-aggregator-ca-config.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "signing": {
    "default": {
      "expiry": "12000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "12000h"
      }
    }
  }
}
EOF

    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/kube-aggregator-ca-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "kube-aggregator-ca",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/kube-aggregator-ca.pem"
    CAKEYFILE="$OUTDIR/kube-aggregator-ca-key.pem"
    CACONFIG=$OUTDIR/kube-aggregator-ca-config.json

    cfssl gencert -initca $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/kube-aggregator-ca
}

# Etcd certificate
# ---------------------------------------------
function write-ssl-etcd {
    # Convert SANs to JSON supported array (e.g 1,2,3 --> "1","2","3",) 
    ETCD_IP=$(for i in $(printf ${SANS} | tr ',' '\n'); do printf "\"$i\","; done)

    # Extracting the IP address from the CN (i.e node-xxx.xxx.xxx.xxx)
    IP_ADDRESS=$(printf ${CN} | awk -F '-' '{print $2}')
    
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "${IP_ADDRESS}",
  "hosts": [
    ${ETCD_IP}
    "127.0.0.1"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "etcd cluster"
    }
  ]
}
EOF

    CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../etcd-ca.pem"
    CAKEYFILE="$OUTDIR/../etcd-ca-key.pem"
    CACONFIG=$OUTDIR/../etcd-ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=etcd $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/etcd
}

# Admin certificate
# ---------------------------------------------
function write-ssl-admin {
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:masters",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/ca.pem"
    CAKEYFILE="$OUTDIR/ca-key.pem"
    CACONFIG=$OUTDIR/ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/admin
}

# Master certificate
# ---------------------------------------------
function write-ssl-master {
    # Convert SANs to JSON supported array (e.g 1,2,3 --> "1","2","3",) 
    MASTER_IP=$(for i in $(printf ${SANS} | tr ',' '\n'); do printf "\"$i\","; done)

    # Extracting the IP address from the CN (i.e node-xxx.xxx.xxx.xxx)
    IP_ADDRESS=$(printf ${CN} | awk -F '-' '{print $2}')

    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "system:node:${IP_ADDRESS}",
  "hosts": [
    "127.0.0.1",
    ${MASTER_IP}
    "localhost",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:nodes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../ca.pem"
    CAKEYFILE="$OUTDIR/../ca-key.pem"
    CACONFIG=$OUTDIR/../ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/${CERTBASE}
}

# Node certificate
# ---------------------------------------------
function write-ssl-node {
    # Convert SANs to JSON supported array (e.g 1,2,3 --> "1","2","3",) 
    NODE_IP=$(for i in $(printf ${SANS} | tr ',' '\n'); do printf "\"$i\","; done)

    # Extracting the IP address from the CN (i.e node-xxx.xxx.xxx.xxx)
    IP_ADDRESS=$(printf ${CN} | awk -F '-' '{print $2}')
    
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "system:node:${IP_ADDRESS}",
  "hosts": [
    "127.0.0.1",
    ${NODE_IP}
    "localhost"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:nodes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../ca.pem"
    CAKEYFILE="$OUTDIR/../ca-key.pem"
    CACONFIG=$OUTDIR/../ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -hostname=${SANS} \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/${CERTBASE}
}

# Kube-Proxy certificate
# ---------------------------------------------
function write-ssl-kube-proxy {
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:node-proxier",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../ca.pem"
    CAKEYFILE="$OUTDIR/../ca-key.pem"
    CACONFIG=$OUTDIR/../ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/${CERTBASE}
}

# Kube-Apiserver certificate
# ---------------------------------------------
function write-ssl-apiserver {
    # Convert SANs to JSON supported array (e.g 1,2,3 --> "1","2","3",) 
    APISERVER_IP=$(for i in $(printf ${SANS} | tr ',' '\n'); do printf "\"$i\","; done)

    # Extracting the IP address from the CN (i.e kube-apiserver-xxx.xxx.xxx.xxx)
    IP_ADDRESS=$(printf ${CN} | awk -F '-' '{print $3}')

    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    ${APISERVER_IP}
    "localhost",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../ca.pem"
    CAKEYFILE="$OUTDIR/../ca-key.pem"
    CACONFIG=$OUTDIR/../ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/${CERTBASE}
}

# Dashboard certificate
# ---------------------------------------------
function write-ssl-dashboard {
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "system:serviceaccount:kube-system:kubernetes-dashboard",
  "hosts": [],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:serviceaccounts:kube-system",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/ca.pem"
    CAKEYFILE="$OUTDIR/ca-key.pem"
    CACONFIG=$OUTDIR/ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/dashboard
}

# Flanneld certificate
# ---------------------------------------------
function write-ssl-flanneld {
    # Convert SANs to JSON supported array (e.g 1,2,3 --> "1","2","3",) 
    ALTERNATIVE_NAMES=$(for i in $(printf ${SANS} | tr ',' '\n'); do printf "\"$i\","; done)

    # Extracting the IP address from the CN (i.e flanneld-xxx.xxx.xxx.xxx)
    HOSTNAME=$(printf ${CN} | awk -F '-' '{print $2}')

    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "${HOSTNAME}",
  "hosts": [
    ${ALTERNATIVE_NAMES}
    "localhost",
    "127.0.0.1"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../ca.pem"
    CAKEYFILE="$OUTDIR/../ca-key.pem"
    CACONFIG=$OUTDIR/../ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/${CERTBASE}
}

# Controller Manager certificate
# ---------------------------------------------
function write-ssl-controller-manager {
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "system:kube-controller-manager",
  "hosts": [],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/ca.pem"
    CAKEYFILE="$OUTDIR/ca-key.pem"
    CACONFIG=$OUTDIR/ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/kube-controller-manager
}

# Scheduler certificate
# ---------------------------------------------
function write-ssl-scheduler {
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "system:kube-scheduler",
  "hosts": [],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:kube-scheduler",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/ca.pem"
    CAKEYFILE="$OUTDIR/ca-key.pem"
    CACONFIG=$OUTDIR/ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/kube-scheduler
}


function write-ssl-service-account {
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "service-accounts",
  "hosts": [],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/ca.pem"
    CAKEYFILE="$OUTDIR/ca-key.pem"
    CACONFIG=$OUTDIR/ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/service-account
}

# Kube-Aggregator client certificate
# ---------------------------------------------
function write-ssl-kube-aggregator-client {
    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "kube-aggregator-client",
  "hosts": [],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Kubernetes cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../kube-aggregator-ca.pem"
    CAKEYFILE="$OUTDIR/../kube-aggregator-ca-key.pem"
    CACONFIG=$OUTDIR/../kube-aggregator-ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=kubernetes $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/kube-aggregator-client
}

# Kube-Apiserver etcd certificate
# ---------------------------------------------
function write-ssl-etcd-client {
    # Convert SANs to JSON supported array (e.g 1,2,3 --> "1","2","3",) 
    APISERVER_IP=$(for i in $(printf ${SANS} | tr ',' '\n'); do printf "\"$i\","; done)

    # Extracting the IP address from the CN (i.e kube-apiserver-xxx.xxx.xxx.xxx)
    IP_ADDRESS=$(printf ${CN} | awk -F '-' '{print $3}')

    # Write cfssl JSON template
    local TEMPLATE=$OUTDIR/${CERTBASE}-csr.json
    echo "local TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
    cat << EOF > $TEMPLATE
{
  "CN": "apiserver-etcd-certificate",
  "hosts": [
    "127.0.0.1",
    ${APISERVER_IP}
    "localhost",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
  ],
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Etcd cluster"
    }
  ]
}
EOF

    local CERTIFICATE=$OUTDIR/${CERTBASE}.pem
    echo "local CERTIFICATE: $CERTIFICATE"
    mkdir -p $(dirname $CERTIFICATE)
    CAFILE="$OUTDIR/../etcd-ca.pem"
    CAKEYFILE="$OUTDIR/../etcd-ca-key.pem"
    CACONFIG=$OUTDIR/../etcd-ca-config.json
    
    cfssl gencert -ca=$CAFILE \
    -ca-key=$CAKEYFILE \
    -config=$CACONFIG \
    -profile=etcd $OUTDIR/${CERTBASE}-csr.json | cfssljson -bare $OUTDIR/${CERTBASE}
}

case "$2" in
    "ca" )
      write-ssl-ca
      ;;
    "kube-aggregator-ca" )
      write-ssl-kube-aggregator-ca
      ;;
    "kube-aggregator-client" )
      write-ssl-kube-aggregator-client
      ;;
    "etcd-ca" )
      write-ssl-etcd-ca
      ;;
    "etcd" )
      write-ssl-etcd
      ;;
    "etcd-client" )
      write-ssl-etcd-client
      ;;
    "admin" )
      write-ssl-admin
      ;;
    "master" )
      write-ssl-master
      ;;
    "node" )
      write-ssl-node
      ;;
    "kube-proxy" )
      write-ssl-kube-proxy
      ;;
    "apiserver" )
      write-ssl-apiserver
      ;;
    "dashboard" )
      write-ssl-dashboard
      ;;
    "flanneld" )
      write-ssl-flanneld
      ;;
    "kube-controller-manager" )
      write-ssl-controller-manager
      ;;
    "kube-scheduler" )
      write-ssl-scheduler
      ;;
    "service-account" )
      write-ssl-service-account
      ;;
esac


KEYFILE="$OUTDIR/$CERTBASE-key.pem"
CSRFILE="$OUTDIR/$CERTBASE.csr"
PEMFILE="$OUTDIR/$CERTBASE.pem"

CONTENTS="${KEYFILE} ${PEMFILE}"

tar -cf $OUTFILE -C $(dirname $CAFILE) "$(basename $CAFILE)"
tar -uf $OUTFILE -C $OUTDIR $(for  f in $CONTENTS;do printf "$(basename $f) ";done)

echo "Bundled SSL artifacts into $OUTFILE"
echo "$CONTENTS"