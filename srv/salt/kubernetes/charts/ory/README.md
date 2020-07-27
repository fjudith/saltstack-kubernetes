# Kratos

## Known issue 

This state leverage the CockroachDB Helm Chart instead of the Rook-CockroachDB operator.
The reason comes from that statefulset name is static with the Rook oprator, leading to conflict between Hydra and other instances localted in the same namespace.

## References

* <https://k8s.ory.sh/helm/>
* <https://github.com/ory/k8s>
* <https://github.com/cockroachdb/helm-charts/tree/master/cockroachdb>