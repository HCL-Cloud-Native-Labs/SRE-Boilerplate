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

## Creating Required PV/Storage Class :

This step would not be required when using a kubernetes installation with a default storage class. But in case you need to create Persistent Volumes (PV) manually then the below 4 PV's would need to be created :

  1. Minio PV
  2. Thanos storegateway PV
  3. Thanos Compactor PV
  4. Thanos Ruler PV 

Example yaml files for all these PV's are present in the repository. Just create these in your cluster by using 

`` kubectl apply -f <filename>``

make sure to list to check all the pv to see that they are available and ready to bind : 
```
kubectl get pv 
NAME                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                   STORAGECLASS                    REASON   AGE
data-thanos-ruler-0-pv          8Gi        RWO,ROX        Retain           Bound    monitoring/data-thanos-ruler-0          data-thanos-ruler-0-pv                   70d
data-thanos-storegateway-0-pv   8Gi        RWO,ROX        Retain           Bound    monitoring/data-thanos-storegateway-0   data-thanos-storegateway-0-pv            70d
thanos-compactor-pv             8Gi        RWO,ROX        Retain           Bound    monitoring/thanos-compactor             thanos-compactor-pv                      70d
thanos-minio-pv                 8Gi        RWO,ROX        Retain           Bound    monitoring/thanos-minio                 thanos-minio-pv                          70d
```

## Install and SetUp minio 

Minio is being used in the thanos setup to provide with an Object Storage API. It provided with an S3 compatible endpoint which then exposes local/NFS storage at the backend. At the backend we can create and assign a local storage space in form of a PV and assign it to minio pod(s) in form of PVC. 

In Thanos , this object storage is used for long term retention of metrics collected from each of the Prometheus. The thanos sidecar in each of the prometheus setup will then be configured to do the remote-write periodically to the minio bucket. 

To install minio use the helm chart for minio :

```
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install thanos-minio bitnami/minio -n monitoring
```
All the default values can be used in the values.yaml. Once the chart is installed wait for minio pod to be created and make sure its up and running : 

```
kubectl get pods -n monitoring | grep minio
thanos-minio-6c9998c78f-sw5kj                         1/1     Running   0              13d
```
## Create a storage bucket in the minio S3 storage and populate the details of bucket in values.yaml

Once you have minio installed , we will need to create a service for minio to expose the minio frontend UI.  We have created a NodePort service for exposing minio, the manifest for the same is uploaded in the repository : thanos-minio-np.yaml 

to create the service : 

```
kubectl create -f thanos-minio-np.yaml -n monitoring
kubectl get svc -n monitoring
```
Use the Node IP and port assigned to minio service to access the frontend. Once you login to the Minio please create a bucket called "thanos" in minio. This bucket would be used to store the metric data for thanos which is collected from all the prometheues sidecars and will act as the log term store for metric data.  

## Download and Install Thanos Bitnami Helm Charts
Now it will be the time to setup Thanos using the bitnami thanos chart. To install the chart :

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install thanos -f values.yaml bitnami/thanos -n monitoring
```

Complete values.yaml file is upload in this repo and contains the runtime configuration of all thanos components like thanos query, thanos bucketweb, thanos compactor, thanos object store etc. Any changes in conifguration needs to be made in this file and then helm release need to be upgraded with the updated values.yaml file. 

Thanos installation(along with minio installation in step 2) will create below pods in the monitoring namespace : 

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
You can now port-forward the thanos-query or thanos-query-frontend pods to access thanos query UI. We will also create a NodePort Service to expose the same. Rest of the components should be okay with ClusterIP type services. 

Also below services would be available for thanos installation : 

```
kubectl get svc -n monitoring | grep -i thanos
kube-prometheus-prometheus-thanos    ClusterIP   None             <none>        10901/TCP                    82d
thanos-bucketweb                     ClusterIP   10.109.190.23    <none>        8080/TCP                     82d
thanos-compactor                     ClusterIP   10.106.47.193    <none>        9090/TCP                     82d
thanos-minio                         ClusterIP   10.100.79.255    <none>        9000/TCP,9001/TCP            82d
thanos-minio-np                      NodePort    10.107.133.27    <none>        9001:30013/TCP               19d
thanos-query                         ClusterIP   10.99.73.202     <none>        9090/TCP,10901/TCP           82d
thanos-query-frontend                ClusterIP   10.107.21.207    <none>        9090/TCP                     82d
thanos-ruler                         ClusterIP   10.105.247.102   <none>        9090/TCP,10901/TCP           82d
thanos-storegateway                  ClusterIP   10.97.130.250    <none>        9090/TCP,10901/TCP           82d
```

To create a Node Port Service for Thanos-query , we can use thanos-query-np.yaml manifest available in the repo. 

```
kubectl apply -f thanos-query-np.yaml -n monitoring 
service/thanos-query-np created

kubectl get svc -n monitoring | grep -i thanos
kube-prometheus-prometheus-thanos    ClusterIP   None             <none>        10901/TCP                    82d
thanos-bucketweb                     ClusterIP   10.109.190.23    <none>        8080/TCP                     82d
thanos-compactor                     ClusterIP   10.106.47.193    <none>        9090/TCP                     82d
thanos-minio                         ClusterIP   10.100.79.255    <none>        9000/TCP,9001/TCP            82d
thanos-minio-np                      NodePort    10.107.133.27    <none>        9001:30013/TCP               19d
thanos-query                         ClusterIP   10.99.73.202     <none>        9090/TCP,10901/TCP           82d
thanos-query-frontend                ClusterIP   10.107.21.207    <none>        9090/TCP                     82d
thanos-query-np                      NodePort    10.102.65.232    <none>        10902:30015/TCP              55s
thanos-ruler                         ClusterIP   10.105.247.102   <none>        9090/TCP,10901/TCP           82d
thanos-storegateway                  ClusterIP   10.97.130.250    <none>        9090/TCP,10901/TCP           82d
```

