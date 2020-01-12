# Kubeless demonstration

## Pre-requisists

A NATS cluster is required to run this demonstration.
Make sure that [nats-operator](https://github.com/nats-io/nats-operator) is enabled in the pillar.

```yaml
kubernetes:
  common:
    addons:
      nats_operator:
        enabled: True
```

If not enabled, run the following command from the salt-master to deploy the NATS cluster.

```bash
salt master01 state.apply kubernetes.addons.nats-operator
```

### Install python modules

Execute the following command to install the Kubernetes and NATS Asynchronous I/O client modules.

```bash
pip3 install kubernetes asyncio-nats-client
```

## Demonstration

### Display Kubernetes events

Execute the following command to return events related to all pods locally.

```bash
python3 print-k8s-events.py
```

```text
...
Event: ADDED Pod rook-ceph-osd-prepare-node02-l7b6p
Event: ADDED Pod kube-scheduler-master01
Event: ADDED Pod node-exporter-kjxnv
```

### Publish Kubernetes events to NATS

Expose the NATS cluster locally.

```bash
kubectl --namespace nats-io port-forward svc/nats-cluster 4222:4222
```

Execute the following command to push Kubernetes events to a NATS queue.

```bash
python3 publish-k8s-events.py --nats-address 'localhost:4222'
```

```text
...
2020-01-11 19:12:30,041 - script - INFO - Event: MODIFIED Pod kube-apiserver-master03
2020-01-11 19:12:35,420 - script - INFO - Event: MODIFIED Pod kube-apiserver-master03
2020-01-11 19:13:01,633 - script - INFO - Event: MODIFIED Pod harbor-harbor-clair-67cf865c6d-qcbt7
```

### Deploy to Kubernetes

Execute the following command to deploy a pod that push Kubernetes events to the NATS cluster

```bash
kubectl apply -f publish-k8s-events-deployment.yaml

# Display logs of the pod
kubectl -n kubeless logs -l app=kubeless-nats-events
```

```text
...
2020-01-11 18:45:04,675 - script - INFO - Event: MODIFIED Pod npd-v0.8.0-cw5bq
2020-01-11 18:45:31,891 - script - INFO - Event: MODIFIED Pod harbor-harbor-database-0
2020-01-11 18:45:36,272 - script - INFO - Event: MODIFIED Pod harbor-harbor-database-0
```

Execute the following command to check that events are effectively published.

```bash
kubeless function deploy test --runtime python3.6 --handler check-k8s-events.dump --from-file check-k8s-events.py --namespace kubeless

# Check that the function is deployed
kubeless function ls -n kubeless
```

Execute the following command to trigger NATS messages in the **same namespace**.

```bash
kubeless trigger nats create test --function-selector created-by=kubeless,function=test --trigger-topic k8s_events --namespace kubeless
```

Execute the following command to cycle the Kubernetes event publisher pod.

```bash
# Delete the current nats event pods
# This will readd all the pods and republish them
kubectl -n kubeless delete po -l app=kubeless-nats-events

# Read the pod logs from the kubeless function we created
kubectl -n kubeless logs -l function=test
```

### Push events to Slack

> A Slack [API Token](https://api.slack.com/custom-integrations/legacy-tokens) and Channel is required to run this demonstration.

Execute the following command to create a function that forward events to [Slack](https://slack.com).

```bash
export SLACK_TOKEN=
export SLACK_CHANNEL=
kubeless function deploy slack --runtime python3.6 --handler slack-k8s-events.slack_message --from-file slack-k8s-events.py --namespace kubeless --env SLACK_TOKEN=$SLACK_TOKEN --env SLACK_CHANNEL=$SLACK_CHANNEL --dependencies requirements.txt

# Read the pod logs from the kubeless function previously created
kubectl -n kubeless logs -l function=slack
```

## Reference

* http://leebriggs.co.uk/blog/2018/10/16/using-kubeless-for-kubernetes-events.html
* https://www.alibabacloud.com/blog/kubeless-a-deep-dive-into-serverless-kubernetes-frameworks-1_594901
* https://github.com/nats-io/asyncio-nats-examples
