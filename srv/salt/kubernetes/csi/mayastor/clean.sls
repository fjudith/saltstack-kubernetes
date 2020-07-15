mayastor-teardown:
  cmd.run:
    - user: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/mayastor/storage-class.yaml
        kubectl delete -f /srv/kubernetes/manifests/mayastor/moac-deployment.yaml
        kubectl delete -f /srv/kubernetes/manifests/mayastor/nats-deployment.yaml
        kubectl delete -f /srv/kubernetes/manifests/mayastor/mayastor-daemonset.yaml
        {# kubectl apply -f /srv/kubernetes/manifests/mayastor/mayastorvolume-crd.yaml #}
        kubectl delete -f /srv/kubernetes/manifests/mayastor/mayastornode-crd.yaml
        kubectl delete -f /srv/kubernetes/manifests/mayastor/mayastorpool-crd.yaml
        
        
        
        
        
        
        
        
        