## Install k3s on Ubuntu 18.04 LTS

### Step1: To install K3s on a one node cluster you simply have to run the following command with root privileges:

	curl -sfL https://get.k3s.io | sh -

This will install the K3s binary under /usr/local/bin/k3s and create multiple symlinks to that binary. The installer will also create a Systemd service unit and start the service with each boot:

	systemctl status k3s.service

Verify the cluster information
	
	kubectl cluster-info
	
	Kubernetes control plane is running at https://127.0.0.1:6443
	CoreDNS is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
	Metrics-server is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy

