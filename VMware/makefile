# Project variables
PROJECT_NAME ?= vmware-create-vm
GIT_HASH := $$(git rev-parse --short HEAD)
VCENTER_CLUSTER := "Noida Cluster"
CLUSTER_NAME := "noi-r940-sre-c2"

# Utility functions
INFO := @ bash -c 'echo "==> $$0 <=="'

.PHONY: download create-dns verify-dns create-oc-cluster cleanup

download:
	${INFO} "Download openshift-installer..."
	wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.9/openshift-install-linux.tar.gz
    gunzip openshift-install-linux.tar.gz && tar xvf openshift-install-linux.tar && ./openshift-install version
	${INFO} "Download openshift-installer completed"

create-dns:
	${INFO} "Create DNS entries in Azure..."
    // terraform initiazation
    //terraform init
    //terraform workspace select $CLUSTER_NAME || terraform workspace new $CLUSTER_NAME
	//terraform apply -auto-approve -var "cluster_id=$CLUSTER_NAME"  -var='api_vip=["'$API_VIP'"]' -var='apps_vip=["'$ING_VIP'"]'
	
    // git branch: 'main', credentialsId: 'CNLABS_GITHUB_TOKEN', \
    // url: 'https://github.com/HCL-Cloud-Native-Labs/OCP_Automation_CFMR_Input.git '
	${INFO} "Done"

verify-dns:
	${INFO} "Verify DNS entries..."
	//dig +short api.$CLUSTER_NAME.hclcnlabs.com
	//dig +short test.apps.$CLUSTER_NAME.hclcnlabs.com
	${INFO} "Done"
	
create-oc-cluster:
	${INFO} "Create Openshift Cluster..."
	./openshift-install create cluster --dir=. --log-level=debug
	${INFO} "Done"



	