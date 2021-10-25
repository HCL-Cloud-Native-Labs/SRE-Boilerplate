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
Start up a root shell for running minikube as your root user.
```
sudo -i
```
# Step 3) Install additional dependencies
Install the following minikube dependencies by running beneath command,
```
sudo apt install -y curl wget apt-transport-https
sudo apt-get install conntrack
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
# Step 6) Add the minikube and localhost IPs to the NO_PROXY IP list.
```
set NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.99.0/24,192.168.39.0/24
```
# Step 7) Start the minikube
As we are already stated in the beginning that we would be using docker as base for minikue, so start the minikube with the docker-env and vm-driver=none,
```
minikube start --vm-driver=none --docker-env NO_PROXY=$NO_PROXY
```
> Minikube start output....
```
* minikube v1.23.2 on Ubuntu 18.04
* Using the none driver based on user configuration
* Starting control plane node minikube in cluster minikube
* Running on localhost (CPUs=4, Memory=16040MB, Disk=59715MB) ...
* OS release is Ubuntu 18.04.6 LTS
* Preparing Kubernetes v1.22.2 on Docker 20.10.7 ...
  - env NO_PROXY=
  - kubelet.resolv-conf=/run/systemd/resolve/resolv.conf
    > kubelet.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubectl.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm.sha256: 64 B / 64 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm: 43.71 MiB / 43.71 MiB [---------------] 100.00% 3.43 MiB p/s 13s
    > kubectl: 44.73 MiB / 44.73 MiB [---------------] 100.00% 3.27 MiB p/s 14s
    > kubelet: 146.25 MiB / 146.25 MiB [-------------] 100.00% 6.61 MiB p/s 22s
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring local host environment ...
*
! The 'none' driver is designed for experts who need to integrate with an existing VM
* Most users should use the newer 'docker' driver instead, which does not require root!
* For more information, see: https://minikube.sigs.k8s.io/docs/reference/drivers/none/
*
! kubectl and minikube configuration will be stored in /root
! To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:
*
  - sudo mv /root/.kube /root/.minikube $HOME
  - sudo chown -R $USER $HOME/.kube $HOME/.minikube
*
* This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
Perfect, above confirms that minikube cluster has been configured and started successfully.

> Run below minikube command to check status,
```
minikube status
```
# Step 8) Deploy the sample application
> Now let’s try a quick deployment named my-nginx by using a container image named nginx previously stored on the docker hub container image registry, with the following command:
```
kubectl create deployment my-nginx --image=nginx
```
> Run following kubectl command to verify deployment status
```
kubectl get deployments.apps my-nginx
kubectl get pods
```
> Expose the deployment using following command,
```
kubectl expose deployment my-nginx --name=my-nginx-svc --type=NodePort --port=80
kubectl get svc my-nginx-svc
```
> Use below command to get your service url,
```
minikube service my-nginx-svc --url
```
# Step 9) Access the service on a web browser
> Open the web browser window with the minikube single node instance external IP(VM IP) and port 31662 i.e http://external_ip:30535

