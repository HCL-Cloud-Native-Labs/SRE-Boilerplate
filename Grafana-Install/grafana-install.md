Grafana is used for visualization of telemetry data collected in various forms like metrics , traces and logs from various observability tools. Grafana provides with an intuitive UI to add new data sources, update data sources and visualisations like Dashboard, Graphs etc for SRE teams, monitoring Operators etc. 

Grafana installation can be done as part of the kube-prometheus Prometheus Operator package . The prometheus operator contains manifest files to setup a Grafana instance and associated primitives on a give kubernetes cluster. The Grafana installation will expect to have at least one Prometheus installation available to connect to . The instructions for installing Promethues can be found at : https://github.com/HCL-Cloud-Native-Labs/SRE-Boilerplate/blob/main/Prometheus-Install/prometheusInstall.md

The github repo for kube-prometheus can be found at : https://github.com/prometheus-operator/kube-prometheus

**Installing Grafana on Kubernetes**
----------------------------------------

The below steps can be followed to install Grafana on to a kubernetes cluster :

1. Clone the repository from https://github.com/prometheus-operator/kube-prometheus to your local system.
``git clone https://github.com/prometheus-operator/kube-prometheus``

2. move into the setup manifests directory and apply the manifests. This will create all the pre-requisite Custom Resources as well as the required RBAC objects (If you have run these manifests already as part of installing Promethues , then you can skip this step).
```
cd kube-prometheus/manifests/setup/
kubectl apply -f .
```
3. Once the objects are created move back to manifests directory (one level up) and apply the manifests to create Grafana components.
```
cd ..
kubectl apply -f grafana*.yaml -n monitoring
```
4. Check the pods created in the monitoring namespace to check if grafana pods have been created and are running. Also check the services to make sure that Grafana is running on port 3000 (ClusterIP).
```
kubectl get pods,svc -n monitoring
```
5. To access the Grafana server , expose the pod by either using port forwarding or by exposing prometheus server.
```
kubectl get deployments -n monitoring | grep -i grafana # get the grafana deployment name 
kubectl expose grafana-deployment-name
```
Access Grafana Server by accessing the NodePort Service Created by accessing URL : https://Node-IP:PORT-Exposed (keep the node port exposed on the port 3000 to keep it simple.). The default login credentials for Grafana would be admin/admin which can then be changed on the first login. 

**Adding a new Data Source in Grafana**
-----------------------------------------
To Be added with screenshots from Grafana UI
  
**Creating a Dashboard in Grafana**
------------------------------------------
To Be added with screenshots from Grafana UI

**Exploring Telemetry Data in Grafana**
-------------------------------------------
To Be added with screenshots from Grafana UI

  
