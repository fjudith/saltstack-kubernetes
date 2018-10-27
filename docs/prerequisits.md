# Pre-requisits

## Windows Subsystem for Linux (Windows user only)

WSL is mandatory to run this project because of [wireguard]() and [jq]() depencies.

Follow the instruction describe [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to install WSL.
Install the **Ubuntu** distribution.

Root user 

## Install Terraform

The project were developped using Terraform v0.11.7, but later version should work well.

```bash
curl -OL https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
unzip terraform_0.11.10_linux_amd64.zip
cp terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm -f terraform terraform_0.11.10_linux_amd64.zip
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