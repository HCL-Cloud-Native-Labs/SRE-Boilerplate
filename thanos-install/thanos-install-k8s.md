Main steps for Thanos installation are as below : 

1. Create the required PV/Storage Class for Thanos components 
2. Setup minio for block storage using minio helm chart
3. Create a storage bucket in the minio S3 storage and populate the details of bucket in values.yaml 
4. Download and Install Thanos Bitnami Helm Charts and provide the correct values.yaml file for custom values
5. Install Thanos SideCar into the prometheus pod and configure it to send the TSDB bloacks to S3 storage
6. On each promethues create a thanos-side car service (except on the lcuster where thanos is installed) and connect that to Thanos Query 
7. Check Thanos Query to make sure that the sidecar and stores are visible into Thanos
8. Add Thanos as the main Metric store in Grafana (instead of all other Prometheus)

Thanos installation is done using the bitnami chart : https://github.com/bitnami/charts/tree/master/bitnami/thanos/ 
Minio installation is done using minio chart : https://github.com/bitnami/charts/tree/master/bitnami/minio 

Thanos is setup on SRE-K8s-CNL cluster in Noida. 3 Node Cluster , Native K8S, servers are sremaster, srenode1, srenode2.  

To install the chart :

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install thanos -f values.yaml bitnami/thanos -n monitoring
```
Complete values.yaml file is upload in the same directory (https://github.com/HCL-Cloud-Native-Labs/SRE-Boilerplate/blob/main/thanos-install/values.yaml). 

This file contains the runtime configuration of all thanos components like thanos query, thanos bucketweb, thanos compactor, thanos object store etc. Any changes in conifguration needs to be made in this file and then helm release need to be upgraded with the updates values.yaml file. 

Thanos installation will create below pods in the monitoring namespace : 

```
## kubectl get pods -n monitoring | grep -i thanos
thanos-bucketweb-7ff7665979-pkr95                     1/1     Running   0              23h
thanos-compactor-6bb887865d-lhjxz                     1/1     Running   0              12d
thanos-minio-6c9998c78f-sw5kj                         1/1     Running   0              12d
thanos-query-69f78dd966-xdshh                         1/1     Running   0              7d1h
thanos-query-frontend-5f6b9cc444-bkk2s                1/1     Running   0              12d
thanos-ruler-0                                        1/1     Running   0              12d
thanos-storegateway-0                                 1/1     Running   0              12d
```
