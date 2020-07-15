openebs-teardown:
  cmd.run:
    - user: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/openebs/storage-class.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/moac-deployment.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/nats-deployment.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/mayastor-daemonset.yaml
        {# kubectl apply -f /srv/kubernetes/manifests/openebs/mayastorvolume-crd.yaml #}
        kubectl delete -f /srv/kubernetes/manifests/openebs/mayastornode-crd.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/mayastorpool-crd.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/jiva-csi.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/csi-operator.yaml
        kubectl delete -f /srv/kubernetes/manifests/openebs/openebs-operator.yaml
        kubectl delete crd blockdeviceclaims.openebs.io
        kubectl delete crd blockdevices.openebs.io
        kubectl delete crd castemplates.openebs.io
        kubectl delete crd cstorbackups.openebs.io
        kubectl delete crd cstorcompletedbackups.openebs.io
        kubectl delete crd cstorpoolinstances.openebs.io
        kubectl delete crd cstorpools.openebs.io
        kubectl delete crd cstorrestores.openebs.io
        kubectl delete crd cstorvolumeclaims.openebs.io
        kubectl delete crd cstorvolumepolicies.openebs.io
        kubectl delete crd cstorvolumereplicas.openebs.io
        kubectl delete crd cstorvolumes.openebs.io
        kubectl delete crd runtasks.openebs.io
        kubectl delete crd storagepoolclaims.openebs.io
        kubectl delete crd storagepools.openebs.io
        kubectl delete crd upgradetasks.openebs.io
        
        
        
        
        
        
        
        
        