# Minikube Installation
> 
# Minimum system requirements for minikube
```
 - 2 GB RAM or more
 - 2 CPU / vCPU or more,
 - 20 GB free hard disk space or more,
 - Docker / Virtual Machine Manager – KVM & VirtualBox,
```
# Step 1) Apply updates
Apply all updates of existing packages of your system by executing the following apt commands,
```
sudo apt update -y
sudo apt upgrade -y
```
# Step 2) Install Docker & enable docker service
Install the Docker and enabling docker service by running beneath command, 
```
sudo apt-get install docker.io
sudo systemctl enable docker
docker --version
```
Add user in docker group, 
> switch to your user (own user) and run following commands
```
sudo groupadd docker
sudo usermod -aG docker $USER
```
> refresh the login session (logout and then login again)
# Step 3) Install Minikube dependencies
Install the following minikube dependencies by running beneath command,
```
sudo apt install -y curl wget apt-transport-https
```
# Step 4) Download Minikube Binary
```
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
```
Once the binary is downloaded, copy it to the path /usr/local/bin and set the executable permissions on it
```
sudo cp minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod +x /usr/local/bin/minikube
```
Verify the minikube version
```
minikube version
minikube version: v1.23.2
commit: 0a0ad764652082477c00d51d2475284b5d39ceed
```
# Step 5) Install Kubectl utility
Kubectl is a command utility which is used to interact with Kubernetes cluster for managing deployments, service and pods etc. Use below curl command to download latest version of kubectl.
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
```
Once kubectl is downloaded then set the executable permissions on kubectl binary and move it to the path /usr/local/bin.
```
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
Now verify the kubectl version
```
kubectl version -o yaml
```
# Step 6) Start the minikube
As we are already stated in the beginning that we would be using docker as base for minikue, so start the minikube with the docker driver,
```
minikube start --driver=docker
```
Perfect, above confirms that minikube cluster has been configured and started successfully.

> Run below minikube command to check status,
```
minikube status
```

