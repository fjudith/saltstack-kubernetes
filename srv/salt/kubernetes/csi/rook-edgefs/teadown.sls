rook-edgefs-teardown:
  cmd.run:
    - runas: root
    - name: |
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/kube-prometheus-prometheus.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/kube-prometheus-service-monitor.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/prometheus-service.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/prometheus.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/service-monitor.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/storage-class.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/storage-class.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/nfs-storageclass.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/iscsi-storageclass.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver-config.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/edgefs-nfs-csi-driver.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/sslKeyCertificate.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/cluster.yaml
        kubectl delete -f /srv/kubernetes/manifests/rook-edgefs/operator.yaml
