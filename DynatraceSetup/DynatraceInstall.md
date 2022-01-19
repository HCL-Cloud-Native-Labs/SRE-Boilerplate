Key Links from Dynatrace documentation. 
  - Dynatrace Documentation : https://www.dynatrace.com/support/help
  - Dynatrace OneAgent Documentation : https://www.dynatrace.com/support/help/setup-and-configuration/dynatrace-oneagent 
  - Dynatrace OneAgent For Kubernetes : https://www.dynatrace.com/support/help/setup-and-configuration/setup-on-container-platforms/kubernetes 

In CNL Labs we are using Dyntrace to observe our kubernetes clusters and below steps will provide guidance to add and discover a kubernetes cluster in Dynatrace.This is done by installing OneAgent on the Kubernetes cluster and then the agent will discover the objects like pods, services etc in the Kubernetes and observe then there on.

Deploying Dynatrace on Kubernetes Cluster :
---------------------------------------------
1. From the cluster console run the below command to get installation script:
```
wget https://github.com/dynatrace/dynatrace-operator/releases/latest/download/install.sh -O install.sh
```
2. Once downloaded run the install script . Installation output similar to below should be produced :
```
sh ./install.sh --api-url "https://rsa14174.live.dynatrace.com/api" --api-token "dt0c01.T2OSBVLJ32DCEUMM7GWGDM5W.C3FLRXCTK3KXF2Z6FNOXFCLZMKKV2ANYR4UFGPW6H4WFQRGR6OVX2HJMVWKKQNQH" --paas-token "dt0c01.LJ3GFYHMZC2D47D7WGD7E5TJ.E6VTA7RKQATJRHSEWPFYJDPQLHHSKQPQ5T2H6QOGBKBJRMY77FMQOBCOGDURF5DJ" --cluster-name "sre-aks-1"

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
