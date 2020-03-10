# EdgeFS

## Connect to Manager toolbox

Run the following command to connec to the toolbox running in rook-edgefs-mgr.

```bash
kubectl exec -it -n rook-edgefs $(kubectl -n rook-edgefs -l app=rook-edgefs-mgr get po -o jsonpath='{range .items[*]}{.metadata.name}') -- env COLUMNS=$COLUMNS LINES=$LINES TERM=linux toolbox
```