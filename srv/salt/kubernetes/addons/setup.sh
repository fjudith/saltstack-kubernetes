#!/bin/bash

cd /srv/salt/post_install/

HELM_VERSION=$(cat ../../pillar/cluster_config.sls |grep helm-version |sed  's/^.*: //g')
CLUSTER_DOMAIN=$(cat ../../pillar/cluster_config.sls |grep domain |sed  's/^.*: //g')

sed -i -e "s/CLUSTER_DOMAIN/$CLUSTER_DOMAIN/g" kube-dns.yaml

kubectl apply -f rbac-calico.yaml
kubectl apply -f /opt/calico.yaml
sleep 10
kubectl create -f coredns.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

kubectl apply -f heapster-rbac.yaml
kubectl apply -f influxdb.yaml
kubectl apply -f grafana.yaml
kubectl apply -f heapster.yaml

wget https://kubernetes-helm.storage.googleapis.com/helm-$HELM_VERSION-linux-amd64.tar.gz
tar -zxvf helm-$HELM_VERSION-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -r linux-amd64/ && rm -r helm-$HELM_VERSION-linux-amd64.tar.gz

kubectl create serviceaccount tiller --namespace kube-system

kubectl apply -f rbac-tiller.yaml
helm init --service-account tiller

sleep 2
echo ""
echo "Kubernetes is now configured with Policy-Controller, Dashboard, Helm and Kube-DNS..."
echo ""
kubectl get pod,deploy,svc --all-namespaces
echo ""
kubectl get nodes
echo ""
