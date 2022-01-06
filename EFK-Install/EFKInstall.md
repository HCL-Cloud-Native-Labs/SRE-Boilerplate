EFK Stack is a well known set of tools to collect, store and visualize logs data. EFK stands for **E**lasticSearch-**F**luentD-**K**ibana. There also an alternate stack called ELK where the FluentD log collection agent is replaced by Logstash log collection agent. In the Labs we are using EFK to store and visualize logs from different clusters. 

EFK stack can be installed and setup on Vanilla K8s clusters, OpenShift Clusters , Anthos, Tanzu and also any flavour of Kubernetes cluster( inluding minikube). In Labs we have setup our EFK stack on an OpenShift Cluster which represents a production-like EFK stack. We will also add the installation instruction for a minikube cluster here, which can be setup on a single-node minikube cluster , representing a training/experimental setup (more suited for the training cohorts).

EFK Installation on OpenShift
---------------------------------

Some Pre-Reading links for Overview of EFK on OpenShift and Setting up of EFK  :

- https://www.openshift.com/blog/introduction-to-the-openshift-4-logging-stack
- https://docs.openshift.com/container-platform/4.6/logging/cluster-logging-deploying.html
- https://github.com/openshift/cluster-logging-operator

Installation of EFK on Openshift is done using an Operator Pattern , which essentially means that in a given Kubernetes/OpenShift Cluster a specific Controller Pod (logging Operator) is setup along with some Custom Resources (Logging CRD's). Then to instantiate a logging instance , the manifests create an object of the created CRD.Once the CRD is instantiated, Opeator pod checks the required configuration and creates the Kubernetes primitive objects (pods, services, deployments etc.) and make sure that these are up and running once created. 

The below steps assume that an OpenShift Cluster is setup and running properly and the user have sufficient permissions to create objects in the cluster. 

1. Create a namespace for Openshift Operator pods. :

```
oc apply -f eo-namespace.yaml
```
*eo-namespace.yaml* contents file are as below :

```
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-operators-redhat 
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
 ```
  
2. Create a namespace for cluster logging components :

```
oc apply -f clo-namespace.yaml
```
*clo-namespace.yaml* file contents are as below :
```
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-logging
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
```
3. Create the operator group & Subscription custom resources . These CRD is defined as part of OpenShift Setup and is needed to install the operator from the Openshift Operator Hub:

```
oc apply -f eo-og.yaml
```

*eo-og.yaml* file contents as below :

```
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-operators-redhat
  namespace: openshift-operators-redhat 
spec: {}
```

```
oc apply -f eo-sub.yaml
```

*eo-sub.yaml* file contents as below: 
```
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: "elasticsearch-operator"
  namespace: "openshift-operators-redhat" 
spec:
  channel: "4.6" 
  installPlanApproval: "Automatic"
  source: "redhat-operators" 
  sourceNamespace: "openshift-marketplace"
  name: "elasticsearch-operator"
 ```
 
 ```
 oc apply -f clo-og.yaml
 ```
 
 *clo-og.yaml* file contents as below :
 ```
 apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: cluster-logging
  namespace: openshift-logging 
spec:
  targetNamespaces:
  - openshift-logging
```

```
oc apply -f clo-sub.yaml
```
*clo-sub.yaml* contents as below:

```
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cluster-logging
  namespace: openshift-logging 
spec:
  channel: "4.6" 
  name: cluster-logging
  source: redhat-operators 
  sourceNamespace: openshift-marketplace
```

4. Once the required CRD's are setup , now we need to decide wether we need to deploy full EFK stack on the cluster or just deploy FluentD log collection agent on the cluster. If we need to deploy the full EFK stack 
```
oc apply -f clo-instance.yaml
```

*clo-instance.yaml* contents as below :

```
apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  name: "instance" 
  namespace: "openshift-logging"
spec:
  managementState: "Managed"  
  logStore:
    type: "elasticsearch"  
    retentionPolicy: 
      application:
        maxAge: 1d
      infra:
        maxAge: 7d
      audit:
        maxAge: 7d
    elasticsearch:
      nodeCount: 3 
      storage:
        storageClassName: "nfs-storage-provisioner" 
        size: 200G
      resources: 
        requests:
          memory: "8Gi"
      proxy: 
        resources:
          limits:
            memory: 256Mi
          requests:
             memory: 256Mi
      redundancyPolicy: "SingleRedundancy"
  visualization:
    type: "kibana"  
    kibana:
      replicas: 1
  curation:
    type: "curator"
    curator:
      schedule: "30 3 * * *" 
  collection:
    logs:
      type: "fluentd"  
      fluentd: {}
```

Also check if the pods are created and running, should look something like below :

```
oc get po -n openshift-logging
NAME                                            READY   STATUS      RESTARTS   AGE
cluster-logging-operator-59cccf46df-skd6x       1/1     Running     0          26m
elasticsearch-cdm-ez64v5f6-1-5854ccb576-gn4v9   2/2     Running     0          17m
elasticsearch-cdm-ez64v5f6-2-794bffc49f-h66gj   2/2     Running     0          16m
elasticsearch-cdm-ez64v5f6-3-79c4668766-shrs5   2/2     Running     0          14m
elasticsearch-im-app-1617370200-vpbbc           0/1     Completed   0          73s
elasticsearch-im-audit-1617370200-l7lx2         0/1     Completed   0          73s
elasticsearch-im-infra-1617370200-cs4jn         0/1     Completed   0          73s
fluentd-9kblg                                   1/1     Running     0          24m
fluentd-k8xsd                                   1/1     Running     0          24m
fluentd-rwfbz                                   1/1     Running     0          24m
fluentd-v5gjx                                   1/1     Running     0          24m
fluentd-vsdsv                                   1/1     Running     0          24m
fluentd-wlp5f                                   1/1     Running     0          24m
kibana-67dbc9ff8d-cmjxs                         2/2     Running     0          24m
```

Setup the log forwarding to the ElasticSerach (from FluentD) :

```
oc apply -f cl-forwarder.yaml
```
*cl-forwarder.yaml* file contents as below :

```
apiVersion: logging.openshift.io/v1
kind: ClusterLogForwarder
metadata:
  name: instance
  namespace: openshift-logging
spec:
  pipelines: 
  - name: all-to-default
    inputRefs:
    - infrastructure
    - application
    - audit
    outputRefs:
    - default
    - elasticsearch-insecure
  outputs:
    - name: elasticsearch-insecure
      type: elasticsearch
      url: http://log-server1.lnd.hclcnlabs.com:9200
```



5. In case we decide to only install FluentD to forward logs from the cluster , apply the below confioguration :

```
oc apply -f clo-instance-fluentd.yaml
```
*clo-instance-fluentd.yaml* contents are as below :

```
apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  name: "instance"
  namespace: "openshift-logging"
spec:
  managementState: "Managed"
  collection:
    logs:
      type: "fluentd"
      fluentd: {}
 ```
 
 check if the fluentD pods are created and running :
 ```
 oc get po -n openshift-logging
NAME                                            READY   STATUS      RESTARTS   AGE
cluster-logging-operator-59cccf46df-skd6x       1/1     Running     0          26m
fluentd-9kblg                                   1/1     Running     0          24m
fluentd-k8xsd                                   1/1     Running     0          24m
fluentd-rwfbz                                   1/1     Running     0          24m
fluentd-v5gjx                                   1/1     Running     0          24m
fluentd-vsdsv                                   1/1     Running     0          24m
fluentd-wlp5f                                   1/1     Running     0          24m
```
Setup log forwarding to ElasticSearch :
```
oc apply -f cl-forwarder-external.yaml
```

check if the fluentD pods are created and running :
```
kind: ClusterLogForwarder
metadata:
  name: instance
  namespace: openshift-logging
spec:
  pipelines:
  - name: all
    inputRefs:
    - infrastructure
    - application
    - audit
    outputRefs:
    - elasticsearch-insecure
    labels:
      clusterId: ocp4-cp4au
      clusterName: CP4AU
      location: London
      infra: Old Intel
  outputs:
    - name: elasticsearch-insecure
      type: elasticsearch
      url: http://log-server1.lnd.hclcnlabs.com:9200
 ```
 
6. The last thing to do would be to expose ElasticSearch : https://docs.openshift.com/container-platform/4.1/logging/config/efk-logging-elasticsearch.html#efk-logging-elasticsearch-exposing_efk-logging-elasticsearch 


EFK Installation on Minikube
--------------------------------


