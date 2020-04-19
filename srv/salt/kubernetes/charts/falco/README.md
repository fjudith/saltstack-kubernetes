# Falco

View logs of all Falco daemonsets.

```bash
kubectl -n falco logs -l app=falco -c falco | grep -e '^\{' | jq
```

## References

* <https://falco.org/docs/grpc/#certificates>
* <https://falco.org/blog/falco-kind-prometheus-grafana/>