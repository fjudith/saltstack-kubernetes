# Kubeless & NATS demonstration

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
python3 local/print-k8s-events.py
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
python3 local/publish-k8s-events.py --nats-address 'localhost:4222'
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
kubectl apply -f manifests/events-deployment.yaml

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
kubeless function deploy test --runtime python3.6 --handler test.dump --from-file functions/test.py --namespace kubeless

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

#### Setup Slack

Create a new [Slack app](https://api.slack.com/apps/new) with the following specifications.

* **App Name**: Python Test
* **Development Slack Workspace**: _Select the appropriate workspace_

Click on the **Create App** button.

In the left panel, select **Bot Users** then click on the **Add a Bot User** button.
Full-fill the **Bot User** as described below:

* **Display Name**: `bot`
* **Default username**: `bot`
* **Always Show My Bot as Online**: _Off_

Click on the **Add Bot User** button.

In the left panel, select **Install App** then click on the **Install app** button.
Click on the **Allow** button.
Backup both the **Oauth Access Token** and **Bot User OAuth Access Token**. This last one will be used as value to the `SLACK_TOKEN` environment variable commummed by the python script.

Execute the following command to test the message publishing to Slack.

```bash
export SLACK_TOKEN= #Bot User Oauth Access Token
export SLACK_CHANNEL=general
python3 slack-client.py -m "Hello world!"
```

#### Deploy the Slack function

Execute the following command to create a function that forward events to [Slack](https://slack.com).

```bash
export SLACK_TOKEN=
export SLACK_CHANNEL=

kubeless function deploy slack --runtime python3.6 --handler slack.slack_message --from-file functions/slack.py --namespace kubeless --env SLACK_TOKEN=$SLACK_TOKEN --env SLACK_CHANNEL=$SLACK_CHANNEL --dependencies functions/requirements.txt

kubeless trigger nats create slack --function-selector created-by=kubeless,function=slack --trigger-topic k8s_events --namespace kubeless

# Read the pod logs from the kubeless function previously created
kubectl -n kubeless logs -l function=slack
```

## Reference

* <http://leebriggs.co.uk/blog/2018/10/16/using-kubeless-for-kubernetes-events.html>
* <https://www.alibabacloud.com/blog/kubeless-a-deep-dive-into-serverless-kubernetes-frameworks-1_594901>
* <https://github.com/nats-io/asyncio-nats-examples>
* <https://slack.dev/python-slackclient/auth.html>
