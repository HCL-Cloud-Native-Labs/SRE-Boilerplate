EFK Stack is a well known set of tools to collect, store and visualize logs data. EFK stands for **E**lasticSearch-**F**luentD-**K**ibana. There also an alternate stack called ELK where the FluentD log collection agent is replaced by Logstash log collection agent. In the Labs we are using EFK to store and visualize logs from different clusters. 

EFK stack can be installed and setup on Vanilla K8s clusters, OpenShift Clusters , Anthos, Tanzu and also any flavour of Kubernetes cluster( inluding minikube). In Labs we have setup our EFK stack on an OpenShift Cluster which represents a production-like EFK stack. We will also add the installation instruction for a minikube cluster here, which can be setup on a single-node minikube cluster , representing a training/experimental setup (more suited for the training cohorts).

EFK Installation on OpenShift
---------------------------------

Some Pre-Reading links for Overview of EFK on OpenShift and Setting up of EFK  :

https://www.openshift.com/blog/introduction-to-the-openshift-4-logging-stack
https://docs.openshift.com/container-platform/4.6/logging/cluster-logging-deploying.html
https://github.com/openshift/cluster-logging-operator

Installation of EFK on Openshift is done using an Operator Pattern , which essentially means that in a given Kubernetes/OpenShift Cluster a specific Controller Pod (logging Operator) is setup along with some Custom Resources (Logging CRD's). Then to instantiate a logging instance , the manifests create an object of the created CRD. 

Once the CRD is instantiated, Opeator pod checks the required configuration and creates the Kubernetes primitive objects (pods, services, deployments etc.) and make sure that these are up and running once created. 






EFK Installation on Minikube
--------------------------------


