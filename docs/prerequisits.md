# Pre-requisits

## Windows Subsystem for Linux (Windows user only)

WSL is mandatory to run this project because of [wireguard]() and [jq]() depencies.

Follow the instruction describe [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to install WSL.
Install the **Ubuntu** distribution.

Root user 

## Install Terraform

The project were developped using Terraform v0.11.7, but later version should work well.

```bash
VERSION=0.11.10
curl -OL https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip
unzip terraform_${VERSION}linux_amd64.zip
cp terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm -f terraform terraform_${VERSION}_linux_amd64.zip
```

## Install Kubectl

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

## Install jq

JQ is required by the Wireguard configuration template processing

```bash
apt-get install jq
```

## Install Wireguard Tools

Wireguard Tools is required to generate the VPN encryption keys

```bash
add-apt-repository -y ppa:wireguard/wireguard
apt-get update
apt-get install wireguard-tools
```

## Install HTTPie (aitch-tee-tee-pie)

HTTPie is an advanced command line HTTP client that works where cURL doesn't (e.g JQuery websites)

```bash
apt-get install httpie
```

## Install Concourse Fly

Fly is required if Concourse is enabled in the salt pillar

```bash
curl -o /usr/local/bin/fly -L https://github.com/concourse/concourse/releases/download/v4.2.1/fly_linux_amd64
chmod +x /usr/local/bin/fly
```