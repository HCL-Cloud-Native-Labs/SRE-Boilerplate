Prometheus is installed in multiple ways depending on the environment in which it is to be installed.

In Labs we are using Prometheus Operator to install Prometheus On Kubernetes. The Prometheus Operator provides Kubernetes native deployment and management of Prometheus and related monitoring components. The purpose of this project is to simplify and automate the configuration of a Prometheus based monitoring stack for Kubernetes clusters.

The Prometheus operator includes, but is not limited to, the following features:

1. Kubernetes Custom Resources: Use Kubernetes custom resources to deploy and manage Prometheus, Alertmanager, and related components.
2. Simplified Deployment Configuration: Configure the fundamentals of Prometheus like versions, persistence, retention policies, and replicas from a native Kubernetes resource.
3. Prometheus Target Configuration: Automatically generate monitoring target configurations based on familiar Kubernetes label queries; no need to learn a Prometheus specific configuration language.

The github repo for kube-prometheus can be found at : https://github.com/prometheus-operator/kube-prometheus 

The below steps can be followed to install prometheus on to a kubernetes cluster :

1. Clone the repository from https://github.com/prometheus-operator/kube-prometheus to your local system. 

`` git clone https://github.com/prometheus-operator/kube-prometheus``

2. move into the setup manifests directory and apply the manifests. This will create all the pre-requisite Custom Resources as well as the required RBAC objects :

```
cd kube-prometheus/manifests/setup/
kubectl apply -f .
```
3. Once the objects are created move back to manifests directory (one level up) and apply the manifests to create Prometheus components. 

```
cd ..
kubectl apply -f prometheus*.yaml -n monitoring
Kubectl apply -f alertmanager*.yaml -n monitoring
kubectl apply -f nodeExporter*.yaml -n monitoring
```
4. Check the pods created in the monitoring namespace to check if prometheus operator pod , prometheus server pod, alertmanager and node-exporter pods have been created and are running. Also check the services to make sure that Prometheus is running on port 9090, alert-manager is running on port 9091 (ClusterIP). 

``
kubectl get pods,svc -n monitoring

```

5. To access the prometheus server , expose the pod by either using port forwarding or by exposing prometheus server.

```
kubectl get deployments -n monitoring | grep -i prometheus # get the prometheus deployment name 
kubectl expose <prometheus-deployment-name>
 ```

