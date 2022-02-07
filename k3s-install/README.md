## Install k3s on Ubuntu 18.04 LTS

### To install K3s on a one node cluster you simply have to run the following command with root privileges:

	curl -sfL https://get.k3s.io | sh -

This will install the K3s binary under /usr/local/bin/k3s and create multiple symlinks to that binary. The installer will also create a Systemd service unit and start the service with each boot:

	systemctl status k3s.service

Verify the cluster information
	
	kubectl cluster-info

output....

	Kubernetes control plane is running at https://127.0.0.1:6443
	CoreDNS is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
	Metrics-server is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy

A kubeconfig file is written to /etc/rancher/k3s/k3s.yaml and the service is automatically started or restarted. The install script will install K3s and additional utilities, such as kubectl, crictl, k3s-killall.sh, and k3s-uninstall.sh, for example:

	sudo kubectl get nodes

K3S_TOKEN is created at /var/lib/rancher/k3s/server/node-token on your server. To install on worker nodes, pass K3S_URL along with K3S_TOKEN or K3S_CLUSTER_SECRET environment variables, for example:

	curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=XXX sh -
	

Please see the [official docs site](https://rancher.com/docs/k3s/latest/en/) for complete documentation.
