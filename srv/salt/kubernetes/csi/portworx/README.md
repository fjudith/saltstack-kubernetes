# Portworx

This state manage the deployment of the [Portworx](https://portworx.com) distributed storage system.

It is required to create an account at [Portworx Central Portal](https://central.portworx.com/) to generate the manifest URL to be configured inside the following pillar data.

```yaml
kubernetes:
  storage:
    portworx:
      enabled: True
      manifest_url: "<portal genrated url>"
      default_storage_class:
        enabled: True
        name: px-dedicated-sc
```

## Useful commands

Run the following commands to check the Portworx cluster status.

```bash
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}') && \
kubectl exec -it $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

## References

* <https://portworx.com>
* <https://docs.portworx.com/install-with-other/operate-and-maintain/monitoring/>
* <https://docs.portworx.com/start-here-installation/>
* <https://central.portworx.com>