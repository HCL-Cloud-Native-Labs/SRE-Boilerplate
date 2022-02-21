To install LitmusChaos , we need to first deploy a control plane component called "ChaosCentre". This component can be setup on  any variety of k8s clusters starting with on-Prem vanilla Kubernetes cluster, OpenShift and all public cloud Kubernetes clusters such as GKE, AKS , EKS etc. The ChaosCentre also installs a "self-agent" with itself so that chaos-expreiments can be run on the cluster where ChaosCentre is setup. For any other cluster Chaos Agents need to be setup by installing the agent binaries on to them. 

LitmusChaos Github Repo ( for source code and installation steps ) : https://github.com/litmuschaos/litmus 
Latest Version : 2.4.0 

Installation of Litmus can be done using either of the below methods : 
1. Helm3 chart
2. Kubectl yaml spec file

Here we will show the Helm method to install LitmusChaos. 

## Install Litmus using Helm

The helm chart will install all the required service account configuration and ChaosCenter.The following steps will help you install Litmus ChaosCenter via helm.

**Step-1**: Add the litmus helm repository

```
helm repo add litmuschaos https://litmuschaos.github.io/litmus-helm/
helm repo list
```

**Step-2**: Create the namespace on which you want to install Litmus ChaosCenter#
The chaoscenter components can be placed in any namespace, though it is typically placed in "litmus".

``kubectl create ns litmus``

**Step-3**: Install Litmus ChaosCenter#

``helm install chaos litmuschaos/litmus --namespace=litmus``

Expected Output
```
NAME: chaos
LAST DEPLOYED: Wed Dec 15 20:18:37 2021
NAMESPACE: litmus
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing litmus 😀
```
Your release is named chaos and it's installed to namespace: litmus.

Visit https://docs.litmuschaos.io to find more info.
**Note**: *Litmus uses Kubernetes CRDs to define chaos intent. Helm3 handles CRDs better than Helm2. Before you start running a chaos experiment, verify if Litmus is installed correctly.*

**Step-4**: Create PersistentVolume and PersistentVolumeClaim 

You would notice that the pods created under will be in pending status because of the fact that they are waiting for the mongo-db pod to start and run. And when you examine the mongo-db pod you would notice that mongo-db pod is not starting because its PVC is unfulfilled. 

We need to therefore create a persistentVolume and attach PersistenntVolumeClaim to it. 

PersistentVolume Manifest :

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongodb-pv1
spec:
  accessModes:
  - ReadWriteOnce
  - ReadOnlyMany
  capacity:
    storage: 20Gi
  hostPath:
    path: /data/mongodb-volume/
    type: ""
  persistentVolumeReclaimPolicy: Retain
  storageClassName: mongodb-pv1
  volumeMode: Filesystem
status:
  phase: Available
```

PersistentVolumeClaim Manifest :

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app.kubernetes.io/component: litmus-database
  name: mongo-persistent-storage-mongo-0
  namespace: litmus
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  volumeMode: Filesystem
  storageClassName: mongodb-pv1
```
Create both object , first PV and then PVC : 
```
kubectl apply -f mongodb-pv.yaml -n litmus
persistentvolume/mongodb-pv1 created

kubectl apply -f mongodb-pvc.yaml -n litmus
persistentvolumeclaim/mongo-persistent-storage-mongo-0 created
```

Now if you check , the pods should have their status as "Running" :

```
kubectl get pods -n litmus
NAME                                     READY   STATUS    RESTARTS   AGE
chaos-litmus-frontend-5ddf54d47b-pwxm9   1/1     Running   0          13m
chaos-litmus-mongo-0                     1/1     Running   0          13m
chaos-litmus-server-674d4bb6bb-6lhsv     2/2     Running   0          13m
```

Now to access Litmus front-end portal, we would need to expose the Frontend service. This can be done by creating a NodePort type of service (https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport). 

An example yaml can be as below : 

```
kind: Service
apiVersion: v1
metadata:
  name: litmus-service
spec:
  type: NodePort
  selector:
          app.kubernetes.io/name: litmus
  ports:
    - nodePort: 30001
      port: 8080
      targetPort: 8080
```
Before creating a nodePort Service also check the existing services inside the litmus namespace, because the installation creates a couple of nodePort services already ( for FrontEnd and For Chaos Server). Therefore in this case we can use these existing services to access Litmus Portal. 

```
kubectl get svc -n litmus | grep -i nodePort
chaos-litmus-frontend-service   NodePort    10.43.242.24    <none>        9091:30814/TCP                                                25h
chaos-litmus-server-service     NodePort    10.43.171.236   <none>        9002:30399/TCP,9003:32238/TCP,8000:30238/TCP,3030:30187/TCP   25h
```
## Installing Litmus Agent
For running the chaos experiment, we need to have a litmus agent installed on the kubernetes cluster. In case of Litmus Control Plane Server, installed on the same server (which is the case for us in this demo), Litmus Agent would be installed once we login to Litmus Control Plane front end for the first time.

To get to the Control plane FrontEnd use URL : https://<K3S-Node-IP>:<NodePortService-Port>
  
The admin-username and admin-password for Litmus Frontend is stored in a secret called "chaos-litmus-admin-secret" in Litmus namespace. These details can be extracted using below commands: 
  
```
kubectl get secret chaos-litmus-admin-secret -o jsonpath="{.data.ADMIN_USERNAME}" -n litmus | base64 --decode ; echo
admin
kubectl get secret chaos-litmus-admin-secret -o jsonpath="{.data.ADMIN_PASSWORD}" -n litmus | base64 --decode ; echo
litmus
```
Use the above credentials into Litmus Frontend .Once you have logged in successfully, come back and check to make sure the new pods specific to Litmus Agent have also been added to Litmus namespace. 
 
Output should look something like the below : 
```
kubectl get pods -n litmus 
NAME                                     READY   STATUS    RESTARTS   AGE
chaos-litmus-frontend-5ddf54d47b-pwxm9   1/1     Running   0          44h
chaos-litmus-mongo-0                     1/1     Running   0          44h
chaos-litmus-server-674d4bb6bb-6lhsv     2/2     Running   0          44h
subscriber-8dcbf4885-ppm58               1/1     Running   0          43h
chaos-exporter-577df9956f-mcfwc          1/1     Running   0          43h
chaos-operator-ce-7656c66856-q7f7k       1/1     Running   0          43h
event-tracker-797965c47-hkz59            1/1     Running   0          43h
workflow-controller-6fd4597874-9dh4m     1/1     Running   0          43h
```

  
## Running Chaos Experiments 
