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

## References

* <https://portworx.com>
* <https://central.portworx.com>