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

Litmus Chaos Experiments are run using the Custom Resources which are installed as part of LitmusChaos Installation. 
  
```
kubectl get crd | grep -i chaos
chaosengines.litmuschaos.io                        2022-02-19T17:40:11Z
chaosexperiments.litmuschaos.io                    2022-02-19T17:40:11Z
chaosresults.litmuschaos.io                        2022-02-19T17:40:11Z
eventtrackerpolicies.eventtracker.litmuschaos.io   2022-02-19T17:40:11Z
```
The first three CRD's , ChaosEngine , ChaosExperiments and ChaosResults are the ones which are used in creating and running a chaos experiments. 

Also we would need a sample app where we can run the chaos-experiemnt ( we will run a pod-delete in this exercise). So we would need to install a sample app. 

Here we will take a very basic app example and deploy the app pod by creating a deployment in default namespace :
```
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1

kubectl get pods 
NAME                                   READY   STATUS    RESTARTS   AGE
kubernetes-bootcamp-57978f5f5d-hpvh6   1/1     Running   0          84s
```
Now we will need to design and run a chaos experiment to delete a pod for this deployment : 

  1. Start by annotating the deployment or the namespace against which you need to run the experiment(``litmuschaos.io/chaos="true"``). For example the below command would annotate the **nginx** deployment. 

```
kubectl annotate deploy/kubernetes-bootcamp litmuschaos.io/chaos="true"
```
  2. Create the RBAC objects ( Service Account, Role and RoleBinding) which will be used to create and execute the ChaosExperiments. It can be done by using the below manifest :

```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: chaos-sa
  namespace: default
  labels:
    name: chaos-sa
    app.kubernetes.io/part-of: litmus
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: chaos-sa
  namespace: default
  labels:
    name: chaos-sa
    app.kubernetes.io/part-of: litmus
rules:
  # Create and monitor the experiment & helper pods
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update", "deletecollection"]
  # Performs CRUD operations on the events inside chaosengine and chaosresult
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create","get","list","patch","update"]
  # Fetch configmaps details and mount it to the experiment pod (if specified)
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get","list",]
  # Track and get the runner, experiment, and helper pods log 
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get","list","watch"]  
  # for creating and managing to execute comands inside target container
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["get","list","create"]
  # deriving the parent/owner details of the pod(if parent is anyof {deployment, statefulset, daemonsets})
  - apiGroups: ["apps"]
    resources: ["deployments","statefulsets","replicasets", "daemonsets"]
    verbs: ["list","get"]
  # deriving the parent/owner details of the pod(if parent is deploymentConfig)  
  - apiGroups: ["apps.openshift.io"]
    resources: ["deploymentconfigs"]
    verbs: ["list","get"]
  # deriving the parent/owner details of the pod(if parent is deploymentConfig)
  - apiGroups: [""]
    resources: ["replicationcontrollers"]
    verbs: ["get","list"]
  # deriving the parent/owner details of the pod(if parent is argo-rollouts)
  - apiGroups: ["argoproj.io"]
    resources: ["rollouts"]
    verbs: ["list","get"]
  # for configuring and monitor the experiment job by the chaos-runner pod
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["create","list","get","delete","deletecollection"]
  # for creation, status polling and deletion of litmus chaos resources used within a chaos workflow
  - apiGroups: ["litmuschaos.io"]
    resources: ["chaosengines","chaosexperiments","chaosresults"]
    verbs: ["create","list","get","patch","update","delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: chaos-sa
  namespace: default
  labels:
    name: chaos-sa
    app.kubernetes.io/part-of: litmus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: chaos-sa
subjects:
- kind: ServiceAccount
  name: chaos-sa
  namespace: default
```
Note down the names of the Objects created , specially the Service Account because this would need to be mentioned in other manifests. You would note that these objects are being created in the Application Namespace so that they would have access to Application resources.
 
  3. Once you have created SA , you can then install all the ChaosExperiments (create the Custom Resources) to make sure these are availbale to you in the cluster.The arrangement of Custom Resources is such that **ChaosEngine** object connects **ChaosExperiment** to an **Application/Deployment** . The **ChaosEngine** object , once it finishes running , also updates the **ChaosResult** object. 

There is a set of pre-defined ChaosExperiments and documentation for these can be found at : https://litmuschaos.github.io/litmus/experiments/categories/contents/ 

All of the Experiments can be installed using the below command 
```
kubectl create -f https://hub.litmuschaos.io/api/chaos/2.3.0?file=charts/generic/experiments.yaml -n <APP_NAMESPACE>
```
Here APP_NAMESPACE would be the namespace when Application is installed ( in this case "de").

Once the experiments have been installed , you can use below command to list out all the ChaosExperiemnt and go through the details of a ChaosExperiment.

```
kubectl get ChaosExperiment -n <APP_NAMESPACE>

kubectl describe ChaosExperiment <CHAOS_EXPERIMENT_NAME> -n <APP_NAMESPACE>
```

4. Once all the required Experiments are installed , Create a **ChaosEngine** Object to connect ChaosExperiment with the Application. This manifest would also mention the ServiceAccount Object which we created earlier. 

An example manifest would look like the below, this one runs a *pod-delete* experiment against kubernetes-bootcamp deployment in default namespace.  Make sure to run the manifest against the APP_NAMESPACE :
```
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: pod-delete
spec:
  engineState: "active"
  annotationCheck: "false"
  appinfo:
    appns: "default"
    applabel: "app=kubernetes-bootcamp"
    appkind: "deployment"
  chaosServiceAccount: chaos-sa
  experiments:
  - name: pod-delete
    spec:
      components:
        env:
        # provided as true for the force deletion of pod
        # supports true and false value
        - name: FORCE
          value: 'true'
        - name: TOTAL_CHAOS_DURATION
          value: '60'
```
Once the ChaosEngine object is created you can make sure that the ChaosEngine is created and running. 
```
kubectl get ChaosEngine -n <APP_NAMESPACE>

kubectl describe ChaosEngine <CHAOS_ENGINE_NAME> -n <APP_NAMESPACE>
```
Sample output for ChaosEngine related events would be as below : 
```
Events:
  Type     Reason                         Age                   From                        Message
  ----     ------                         ----                  ----                        -------
  Normal   ChaosEngineInitialized         3m20s                 chaos-operator              Identifying app under test & launching pod-delete-runner
  Warning  ChaosResourcesOperationFailed  3m20s                 chaos-operator              (chaos running) Unable to check chaos status
  Normal   ExperimentDependencyCheck      3m7s                  pod-delete-runner           Experiment resources validated for Chaos Experiment: pod-delete
  Normal   ExperimentJobCreate            3m7s                  pod-delete-runner           Experiment Job pod-delete-om1c18 for Chaos Experiment: pod-delete
  Normal   PreChaosCheck                  2m35s                 pod-delete-om1c18--1-dd2q2  AUT: Running
  Normal   ChaosInject                    100s (x7 over 2m35s)  pod-delete-om1c18--1-dd2q2  Injecting pod-delete chaos on application pod
  Normal   PostChaosCheck                 87s                   pod-delete-om1c18--1-dd2q2  AUT: Running
  Normal   Summary                        83s                   pod-delete-om1c18--1-dd2q2  pod-delete experiment has been Passed
  Normal   ExperimentJobCleanUp           71s                   pod-delete-runner           Experiment Job pod-delete-om1c18 will be retained
  Normal   ChaosEngineCompleted           71s                   chaos-operator              ChaosEngine completed, will delete or retain the resources according to jobCleanUpPolicy
```
It will mention in the events as to which pods executed the different actions and also if the ChaosExperiment was successfull or not(Passed/Failed). 
  
5. Check for any ChaosResult Objects created and their status (Success/Fail). 

```
kubectl get ChaosResult -n <APP_NAMESPACE>

kubectl describe ChaosResult <CHAOS_RESULT_NAME> -n <APP_NAMESPACE>
```
Sample output would look like below : 
```
kubectl describe ChaosResults pod-delete-pod-delete
Name:         pod-delete-pod-delete
Namespace:    default
Labels:       app.kubernetes.io/component=experiment-job
              app.kubernetes.io/part-of=litmus
              app.kubernetes.io/version=2.3.0
              chaosUID=77610660-8c97-4a6d-a0b0-b750e2ecd331
              controller-uid=42edec6e-b3a9-418c-af2b-7ad5a03d5831
              job-name=pod-delete-om1c18
              name=pod-delete
Annotations:  <none>
API Version:  litmuschaos.io/v1alpha1
Kind:         ChaosResult
Metadata:
  Creation Timestamp:  2022-02-21T15:19:25Z
  Generation:          2
  Managed Fields:
    API Version:  litmuschaos.io/v1alpha1
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:labels:
          .:
          f:app.kubernetes.io/component:
          f:app.kubernetes.io/part-of:
          f:app.kubernetes.io/version:
          f:chaosUID:
          f:controller-uid:
          f:job-name:
          f:name:
      f:spec:
        .:
        f:engine:
        f:experiment:
      f:status:
        .:
        f:experimentStatus:
        f:history:
    Manager:         experiments
    Operation:       Update
    Time:            2022-02-21T15:19:25Z
  Resource Version:  88455
  UID:               27ed613b-3398-4da3-8fdf-20481f51be74
Spec:
  Engine:      pod-delete
  Experiment:  pod-delete
Status:
  Experiment Status:
    Fail Step:                 N/A
    Phase:                     Completed
    Probe Success Percentage:  100
    Verdict:                   Pass
  History:
    Failed Runs:   0
    Passed Runs:   1
    Stopped Runs:  0
    Targets:
      Chaos Status:  targeted
      Kind:          deployment
      Name:          kubernetes-bootcamp
Events:
  Type    Reason   Age    From                        Message
  ----    ------   ----   ----                        -------
  Normal  Awaited  4m43s  pod-delete-om1c18--1-dd2q2  experiment: pod-delete, Result: Awaited
  Normal  Pass     3m27s  pod-delete-om1c18--1-dd2q2  experiment: pod-delete, Result: Pass
```
You would see that Initially when the ChaosEngine was running the Chaos Result was set to Awaited and when it finished it showed Pass , this is because in this simple experiemnt Kubernetes was able to recover the pod quickly without any disruption and therefore the ChaosEngine deemed the result as Pass. 

More details can be found at : https://litmuschaos.github.io/litmus/experiments/concepts/chaos-resources/contents/
