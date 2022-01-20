Key Links from Dynatrace documentation. 
  - Dynatrace Documentation : https://www.dynatrace.com/support/help
  - Dynatrace OneAgent Documentation : https://www.dynatrace.com/support/help/setup-and-configuration/dynatrace-oneagent 
  - Dynatrace OneAgent For Kubernetes : https://www.dynatrace.com/support/help/setup-and-configuration/setup-on-container-platforms/kubernetes 

In CNL Labs we are using Dyntrace to observe our kubernetes clusters and below steps will provide guidance to add and discover a kubernetes cluster in Dynatrace.This is done by installing OneAgent on the Kubernetes cluster and then the agent will discover the objects like pods, services etc in the Kubernetes and observe then there on.

Deploying Dynatrace on Kubernetes Cluster :
---------------------------------------------
Dynatrace OneAgent is installed on a Kubernetes cluster using the DynaKube Operator. This means that the installation script first installs the required Custom Resources on the cluster, creates and starts a DynaKube Operator Pod and then instantiates a Dynatrace OneAgent Custom Resource Object. The script also creates a namespace on the cluster called "Dynatrace" which holds all the Dynatrace related objects.

Dyntrace Operator works like a controller to make sure that the Dynatrace OneAgent Custom Resource (and supporting native objects like pods, services etc.) are all up and running as per the requied configuration. 

To install Dynatrace OneAgent follow the below steps :

1. From the cluster console run the below command to get installation script:
```
wget https://github.com/dynatrace/dynatrace-operator/releases/latest/download/install.sh -O install.sh
```
2. Once downloaded run the install script . Installation output similar to below should be produced :
```
sh ./install.sh --api-url "https://rsa14174.live.dynatrace.com/api" --api-token <API_TOKEN> --paas-token <API_TOKEN> --cluster-name "sre-aks-1"

Check for token scopes...

Check if cluster already exists...

Creating Dynatrace namespace...
namespace/dynatrace created

Applying Dynatrace Operator...
customresourcedefinition.apiextensions.k8s.io/dynakubes.dynatrace.com created
mutatingwebhookconfiguration.admissionregistration.k8s.io/dynatrace-webhook created
serviceaccount/dynatrace-activegate created
serviceaccount/dynatrace-dynakube-oneagent created
serviceaccount/dynatrace-dynakube-oneagent-unprivileged created
serviceaccount/dynatrace-kubernetes-monitoring created
serviceaccount/dynatrace-operator created
serviceaccount/dynatrace-routing created
serviceaccount/dynatrace-webhook created
role.rbac.authorization.k8s.io/dynatrace-operator created
role.rbac.authorization.k8s.io/dynatrace-webhook created
clusterrole.rbac.authorization.k8s.io/dynatrace-kubernetes-monitoring created
clusterrole.rbac.authorization.k8s.io/dynatrace-operator created
clusterrole.rbac.authorization.k8s.io/dynatrace-webhook created
rolebinding.rbac.authorization.k8s.io/dynatrace-operator created
rolebinding.rbac.authorization.k8s.io/dynatrace-webhook created
clusterrolebinding.rbac.authorization.k8s.io/dynatrace-kubernetes-monitoring created
clusterrolebinding.rbac.authorization.k8s.io/dynatrace-operator created
clusterrolebinding.rbac.authorization.k8s.io/dynatrace-webhook created
service/dynatrace-webhook created
deployment.apps/dynatrace-operator created
deployment.apps/dynatrace-webhook created
validatingwebhookconfiguration.admissionregistration.k8s.io/dynatrace-webhook created
secret/dynakube created

Wait for webhook to become available
pod/dynatrace-webhook-78768bd789-2z5md condition met

Applying DynaKube CustomResource...
CR.yaml:
----------
apiVersion: dynatrace.com/v1beta1
kind: DynaKube
metadata:
  name: dynakube
  namespace: dynatrace
spec:
  apiUrl: https://rsa14174.live.dynatrace.com/api
  skipCertCheck: false
  networkZone: sre-aks-1
  oneAgent:
    classicFullStack:
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists

      args:
      - --set-host-group=sre-aks-1
  activeGate:
    capabilities:
      - routing
      - kubernetes-monitoring
    group: sre-aks-1
----------
dynakube.dynatrace.com/dynakube created

Adding cluster to Dynatrace...
Kubernetes monitoring successfully setup
```
3. Once the agent has been setup properly , you can check in the Dynatrace portal Under the "Workloads" and "Services" section and you should be able to see details of your clusters ( Workloads, Pods, Services etc.) discovered in Dynatrace. 
For the application traces , Dynatrace natively picks up traces and metrics from applications in most langauges (like Java, NodeJS, Go , Python etc.). But if there are some applications for which the traces are not getting picked up , the application can be instrumented with the Dynaytrace OneAgent SDK. 

  - Dyntrace OneAgent SDK : https://www.dynatrace.com/support/help/extend-dynatrace/oneagent-sdk 
  - Dyntrace Technology Support Matrix : https://www.dynatrace.com/support/help/technology-support/oneagent-platform-and-capability-support-matrix 

