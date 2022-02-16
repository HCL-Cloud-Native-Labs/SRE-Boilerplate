**Flow for Demo :** 

1. What is Kubernetes primitive objects ( Pods ,Services, deployments etc.) 
2. What is Helm 
3. What is Operator Pattern 
4. Helm Overview and Install 
5. Lens Overview and Install 
6. Prometheus Grafana Install using Kube-Operator 
7. Grafana Overview
8. Check datasources , how to add them 
9. Check Dashboards , how to create a new one/import a new one (Kubernetes API Server , SLO details etc) 
10. Login to Prometheus 
	- Look at Targets 
	- Looks at AlertManager Rules
	- Configuration view 
	
11. Explain Node_exporters , Service Monitors, Pod Monitors
12. Prometheus Metric Types :
	- Counter
	- Gauge
	- Histogram
	- Summary
13. Sample instrumentation using Python  and show how the endpoint will expose the metrics 
14. Loki & Promtail installation & configuration 
15. Explore metrics and Logs from Grafana
16. Show sample configuration from Vendor based/PaaS tools - to add a cluster 
	- Dynatrace
	- AppDynamics



**Installing Helm :**
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

**Install Lens - IDE for Kubernetes(optional but recommended) :**

Download Lens IDE from https://k8slens.dev/ as per the Client OS and install

**Installing Prometheus Operator :**

Github repo for Prometheus Operator : https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack 

Perform below steps on your k3s cluster. (This was installed in the second week demo)
```
kubectl create ns monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

helm install prometheus --namespace monitoring prometheus-community/kube-prometheus-stack
NAME: prometheus
LAST DEPLOYED: Fri Feb 11 10:00:36 2022
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```
Start Prometheus, AlertManager & Grafana by port-forward 

```
kubectl port-forward svc/prometheus-grafana 8080:80
kubectl port-forward svc/prometheus-prometheus-oper-prometheus 9090
kubectl port-forward svc/prometheus-prometheus-oper-alertmanager 9093
```

Check the secret “prom-operator” to check username and password or by command as below : 

```
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo
admin
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
prom-operator
```

If Grafana service doesnt open correctly at first , try to edit k3s service to allow :  
```
sudo systemctl edit k3s.service

### Editing /etc/systemd/system/k3s.service.d/override.conf
### Anything between here and the comment below will become the new contents of the file

[Service]
ExecStart=
ExecStart=/usr/local/bin/k3s \
    server \
      '--flannel-backend=host-gw'

### Lines below this comment will be discarded
```
Sample Prometheus Instrumention (Python client library) :
1. First install prometheus client library on your host :

```
sudo apt install python3
sudo apt install python3-pip
pip3 install prometheus_client
```
2. Create below sample python code (prometheus_pyClient.py) locally and save. 

```
#!/usr/bin/env python3
from prometheus_client import start_http_server, Summary
import random
import time

# Create a metric to track time spent and requests made.
REQUEST_TIME = Summary('request_processing_seconds', 'Description: Time spent processing request(custom metrics)')

# Decorate function with metric.
@REQUEST_TIME.time()
def process_request(t):
        """A dummy function that takes some time."""
        time.sleep(t)

if __name__ == '__main__':
    # Start up the server to expose the metrics.
    start_http_server(8000)
    # Generate some requests.
    while True:
        process_request(random.random())
 ```
 3. Run the script and check at http://localhost:8000 to see if the custom metrics are visible for scraping endpoint

**Loki & Promtail Install:**

Steps to Install Loki and Promtail :

```
helm repo add grafana https://grafana.github.io/helm-charts
Heml repo update

kubectl create ns loki

helm upgrade --install loki --namespace=loki grafana/loki
Release "loki" does not exist. Installing it now.
W0211 16:30:38.454620   31726 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W0211 16:30:38.476261   31726 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
NAME: loki
LAST DEPLOYED: Fri Feb 11 16:30:38 2022
NAMESPACE: loki
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Verify the application is working by running these commands:
  kubectl --namespace loki port-forward service/loki 3100
  curl http://127.0.0.1:3100/api/prom/label

helm upgrade --install promtail grafana/promtail --set "loki.serviceName=loki" -n loki
Release "promtail" does not exist. Installing it now.
NAME: promtail
LAST DEPLOYED: Fri Feb 11 16:35:42 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
***********************************************************************
 Welcome to Grafana Promtail
 Chart version: 3.11.0
 Promtail version: 2.4.2
***********************************************************************

Verify the application is working by running these commands:

* kubectl --namespace loki port-forward daemonset/promtail 3101
* curl http://127.0.0.1:3101/metrics
```

Use the IP of Loki service and add a new data source in Grafana :
```
http://<Loki-Service-IP>:3100
```
Promtail configuration documentation : https://grafana.com/docs/loki/latest/clients/promtail/configuration/ 

Check that promtail is sending logs correctly to Loki.Add Loki as data source and check the logs. 
