openebs-teardown:
  cmd.run:
    - user: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/openebs/storage-class.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/moac-ddeployment.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/nats-deployment.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/mayastor-daemonset.yaml
        {# kubectl apply -f /srv/kubernetes/manifests/openebs/mayastorvolume-crd.yaml #}
        kubectl delete -f /srv/kubernetes/manifests/openebs/mayastornode-crd.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/mayastorpool-crd.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/jiva-csi.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/csi-operator.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/operator.yaml
        
        
        
        
        
        
        
        
        