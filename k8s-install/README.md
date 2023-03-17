## Install Kubernetes on Ubuntu 20.04 LTS 

### Step1: `On All Machines ( Master & All nodes ):`

    sudo apt update
    
    swapoff -a

    sudo apt install docker.io -y
    
    sudo apt install apt-transport-https curl -y
    
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
    
    sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    
    sudo apt update
    
    sudo modprobe br_netfilter

    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
	net.bridge.bridge-nf-call-iptables = 1
	net.ipv4.ip_forward = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	EOF

    sudo sysctl --system

    sudo apt update
    
    sudo apt install kubeadm kubelet kubectl kubernetes-cni -y
    
    sudo rm -rf /etc/containerd/config.toml
    
    sudo systemctl restart containerd

### Step2: `On Master only:`

    sudo kubeadm init --pod-network-cidr 192.168.0.0/16
	
    sudo mkdir -p $HOME/.kube
    
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
    kubectl get nodes

    curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
    
    kubectl apply -f calico.yaml
    
    kubeadm token create --print-join-command    (Run only if you forget the Token)

### Step3: `On Nodes only:`
       
    copy the kubeadm join token from master & run it on all nodes
          
    Ex: kubeadm join 10.128.15.231:6443 --token mks3y2.v03tyyru0gy12mbt \
           --discovery-token-ca-cert-hash sha256:3de23d42c7002be0893339fbe558ee75e14399e11f22e3f0b34351077b7c4b56



## Install Kubernetes on CENTOS 

### Step1: `On All Machines ( Master & All nodes ):`

     ### Set SELinux in permissive mode (effectively disabling it)
     
     setenforce 0
     sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

     ### Install Docker
     
     sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine docker-ce docker-ce-cli containerd.io
     sudo yum install -y yum-utils device-mapper-persistent-data lvm2
     sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
     sudo yum install -y docker-ce docker-ce-cli containerd.io
     systemctl enable --now docker
     systemctl start docker

     ### Install kubeadm,kubelet,kubectl
     
     cat <<EOF > /etc/yum.repos.d/kubernetes.repo
     [kubernetes]
     name=Kubernetes
     baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
     enabled=1
     gpgcheck=1
     repo_gpgcheck=1
     gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
     EOF

     yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
     systemctl enable --now kubelet

### Step2: `On Master only:`

    sudo kubeadm init --pod-network-cidr=10.244.0.0/16

    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

    kubectl get nodes
    kubectl get all --all-namespaces

### Step3: `On Nodes only:`

    copy the kubeadm join token from master & run it on all nodes

    Ex: kubeadm join 10.128.15.231:6443 --token mks3y2.v03tyyru0gy12mbt \
           --discovery-token-ca-cert-hash sha256:3de23d42c7002be0893339fbe558ee75e14399e11f22e3f0b34351077b7c4b56




## how to find kubeadm join token later
```
kubeadm token create --print-join-command --ttl=0
```


## FYI Only: Reconstructing the Join Command for Kubeadm

```
skeleton of a kubeadm join command for a control plane node:

kubeadm join <endpoint-ip-or-dns>:<port> \
--token <valid-bootstrap-token> \
--discovery-token-ca-cert-hash <ca-cert-sha256-hash> \
--control-plane \
--certificate-key <certificate-key>
```

```
skeleton of a kubeadm join command for a worker node:

kubeadm join <endpoint-ip-or-dns>:<port> \
--token <valid-bootstrap-token> \
--discovery-token-ca-cert-hash <ca-cert-sha256-hash> \
```  

```
get the controleplane IP:PORT: kubectl cluster-info

list exsiting tokens: kubeadm token list

Create kubeadm bootstrap token: kubeadm token create

find ca-cert-hash with openssl:
   openssl x509 -in /etc/kubernetes/pki/ca.crt -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256
```

## MORE INFO: [Kubeam join](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/)


CAPACITY:
=========

At v1.19, Kubernetes supports clusters with up to 5000 nodes. More specifically, we support configurations that meet all of the following criteria:

No more than 5000 nodes

No more than 150000 total pods

No more than 300000 total containers

No more than 100 pods per node

