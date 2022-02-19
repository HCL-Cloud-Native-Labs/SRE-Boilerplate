To install LitmusChaos , we need to first deploy a control plane component called "ChaosCentre". This component can be setup on  any variety of k8s clusters starting with on-Prem vanilla Kubernetes cluster, OpenShift and all public cloud Kubernetes clusters such as GKE, AKS , EKS etc. The ChaosCentre also installs a "self-agent" with itself so that chaos-expreiments can be run on the cluster where ChaosCentre is setup. For any other cluster Chaos Agents need to be setup by installing the agent binaries on to them. 

LitmusChaos Github Repo ( for source code and installation steps ) : https://github.com/litmuschaos/litmus 
Latest Version : 2.4.0 

Installation of Litmus can be done using either of the below methods : 
1. Helm3 chart
2. Kubectl yaml spec file

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

## Install Litmus using kubectl

**Step-1** : Install using the manifest from LitmusChaos github
Applying the manifest file will install all the required service account configuration and ChaosCenter.

``kubectl apply -f https://litmuschaos.github.io/litmus/2.4.0/litmus-2.4.0.yaml``

If you are installing Litmus in any other namespace apart from litmus namespace, make sure to change the same in the manifest too https://litmuschaos.github.io/litmus/2.4.0/litmus-2.4.0.yaml.

**Step-2**: Verify your installation
Verify if the frontend, server, and database pods are running . Check the pods in the namespace where you installed Litmus:
```
kubectl get pods -n litmus
Expected Output
NAME                                    READY   STATUS  RESTARTS  AGE
litmusportal-frontend-97c8bf86b-mx89w   1/1     Running 2         6m24s
litmusportal-server-5cfbfc88cc-m6c5j    2/2     Running 2         6m19s
mongo-0                                 1/1     Running 0         6m16s
```
Check the services running in the namespace where you installed Litmus:
```
kubectl get svc -n litmus
Expected Output
NAME                            TYPE        CLUSTER-IP      EXTERNAL-IP PORT(S)                       AGE
litmusportal-frontend-service   NodePort    10.100.105.154  <none>      9091:30229/TCP                7m14s
litmusportal-server-service     NodePort    10.100.150.175  <none>      9002:30479/TCP,9003:31949/TCP 7m8s
mongo-service                   ClusterIP   10.100.226.179  <none>      27017/TCP                     7m6s
```

**Step-3**:Verify Successful Registration of the Self Agent post Account Configuration#
Once the project is created, the cluster is automatically registered as a chaos target via installation of ChaosAgents. This is represented as Self-Agent in ChaosCenter.
```
kubectl get pods -n litmus
NAME                                     READY   STATUS    RESTARTS   AGE
chaos-exporter-547b59d887-4dm58          1/1     Running   0          5m27s
chaos-operator-ce-84ddc8f5d7-l8c6d       1/1     Running   0          5m27s
event-tracker-5bc478cbd7-xlflb           1/1     Running   0          5m28s
litmusportal-frontend-97c8bf86b-mx89w    1/1     Running   0          15m
litmusportal-server-5cfbfc88cc-m6c5j     2/2     Running   1          15m
mongo-0                                  1/1     Running   0          15m
subscriber-958948965-qbx29               1/1     Running   0          5m30s
workflow-controller-78fc7b6c6-w82m7      1/1     Running   0          5m32s
```
You would also need to create a NodePort type of service to expose the ChaosCentre ( litmusportal-frontend), a typical manifest file for NodePort service would be as below :
 ```
 <Insert-Code-here-from-Noida-SRE-Box>
 ``` 
At this point you should have a ChaosCentre setup and running at : <Insert-URL> , where you can login using the default login credentials : *admin/litmus*

 Once you login you would notice that along with the control plane components, a self-agent has been installed on the same cluster. This now means that we can run chaos "workflows" on the applications setup on the given cluster where ChaosCentre is installed. 

## Adding Agents to ChaosCentre 
Once the ChaosCentre is up and setup and we can next attach other clusters in your enviornments ( on-prem or cloud ) to your LitmusChaos installation. This is done by installing an agent on each of the clusters that you want to run ChaosExperiments. 

Installation/update/deletion of an agent is done using a command line untility provided by LitmusChaos called **"litmusctl"**. litmusctl is available as a binary from litmus team and can be downloaded from links given at : https://docs.litmuschaos.io/docs/litmusctl/installation 

Once downloaded please make sure that below pre-requisites are met :
  
Litmusctl CLI requires the following things:

1. kubeconfig - litmusctl needs the kubeconfig of the k8s cluster where we need to connect litmus agents. The CLI currently uses the default path of kubeconfig i.e. ~/.kube/config.
2. kubectl - litmusctl is using kubectl under the hood to apply the manifest

To extract and use litmusctl follow the below steps :     
**Linux/MacOS**
1. Extract the binary
``tar -zxvf litmusctl-<OS>-<ARCH>-<VERSION>.tar.gz``
  
2. Provide necessary permissions
``chmod +x litmusctl``
  
3. Move the litmusctl binary to /usr/local/bin/litmusctl. Note: Make sure to use root user or use sudo as a prefix
``mv litmusctl /usr/local/bin/litmusctl``
  
4. You can run the litmusctl command in Linux/macOS:
``litmusctl <command> <subcommand> <subcommand> [options and parameters]``
    
5. Litmus Agent install : 
```
  litmusctl get-accounts # checks which ChaosCentre Litmus Server instances are currently configured for litmusctl 
  litmusctl config get-accounts
  litmusctl configure # In case the required ChaosCentre instance is not configured setup, then litmusctl to talk to ChaosCentre Litmus Server instance 
  litmusctl config set-account --endpoint="" --username="" --password=""
  litmusctl config use-account --endpoint="" --username="" ( if the required server is added but is not the one in use by litmusctl)
  litmusctl create agent : This downloads the latests manifests from the litmusctl server and applies the same on to the current cluster (as defined in the kubeconfig) and creates the required components (pods/services) under litmus namespace
  litmusctl create agent --agent-name="" --project-id=""
 ```
6. Once the agent is installed , login into the ChaosCentre and check under ChaosAgents to make sure you can see the agent that you installed showing as "Active". Now the cluster is available to run ChaosExperiments. 
  
