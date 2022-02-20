To install LitmusChaos , we need to first deploy a control plane component called "ChaosCentre". This component can be setup on any variety of k8s clusters starting with on-Prem vanilla Kubernetes cluster, OpenShift and all public cloud Kubernetes clusters such as GKE, AKS , EKS etc. The ChaosCentre also installs a "self-agent" with itself so that chaos-expreiments can be run on the cluster where ChaosCentre is setup. For any other cluster Chaos Agents need to be setup by installing the agent binaries on to them.

LitmusChaos Github Repo ( for source code and installation steps ) : https://github.com/litmuschaos/litmus Latest Version : 2.4.0

