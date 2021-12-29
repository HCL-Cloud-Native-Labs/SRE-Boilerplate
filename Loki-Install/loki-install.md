**General process to install Loki:**
Overall in order to install and run Loki for log collection , Following steps need to be followed.

1. Download and install both Loki and Promtail.
2. Download config files for both programs.
3. Start Loki.
4. Update the Promtail config file to get your logs into Loki.
4. Start Promtail.

For lab environment we are following the Helm based installation of Loki into Kubernetes clusters. This method should work for clusters of all kind , including minikube. 

Install Grafana Loki with Helm
-------------------------------

1. As a pre-requisite, make sure you have Helm installed.

2. Add Loki’s chart repository to Helm and update your chart repository:
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
3. Create a namespace for Loki installation : 
`` kubectl create ns loki``

4. If you are deploying on a fresh cluster , where there are no previous tools deployed like Prometheus, Grafana you can go for full stack installation which will include Loki, Promtail , Prometheus and Grafana on the same cluster ( and namespace). Run below command to install the full stack :
```
helm upgrade --install loki grafana/loki-stack  --namespace=loki --set grafana.enabled=true,prometheus.enabled=true,prometheus.alertmanager.persistentVolume.enabled=false,prometheus.server.persistentVolume.enabled=false,loki.persistence.enabled=true,loki.persistence.storageClassName=standard,loki.persistence.size=5Gi
```
5. Else if you already have other tools installed on your cluster and just want to install Loki and connect it with the existing toolset later , you can run the below command :
```
helm upgrade --install loki --namespace=loki grafana/loki
```
6. Keep in mind that once you have installed Loki ( as in the last step) you would have to install Promtail on the servers, clusters and pods from where you want to bring in logs. Steps to install Promtail and configure promtail are provided next in this manual. 

Install and Configure Promtail
--------------------------------

1. Once you have installed Loki and the pods and svc are up and availbale. Next steps would be to setup Promtail agents at multiple places from where you need to bring in the logs into Loki. There are multiple ways in which promtail can be installed. 

**Installation using Helm**
Installation using Helm should be used in case of single node cluster from where logs are to be brought into Loki.
. Make sure that Helm is installed. Then you can add Grafana’s chart repository to Helm:
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
. Finally, Promtail can be deployed with:
```
$ helm upgrade --install promtail grafana/promtail --set "loki.serviceName=loki"
```
Here *loki.servicename* needs to be the loki service which is configured in Loki installation namespace. If the name of the service is set as some thing else, use that service name instead. 

**Installation Using kubernetes Daemonset**
In case of a multi node kubernetes cluster , installation of Promtail agent is recommended to be done using a daemonset object. This ensure that one agent is installed on each of the nodes in the cluster.

. Copy the example manifest at : https://github.com/HCL-Cloud-Native-Labs/SRE-Boilerplate/blob/main/Loki-Install/promtail-daemonset-install.yaml
. Create a namespace and apply the manifest. 
```
kubectl create ns loki
kubectl apply -f promtail-daemonset-install.yaml
```
. Check if the pods for promtail have been created and are running 
```
kubectl get pods -n loki
```
