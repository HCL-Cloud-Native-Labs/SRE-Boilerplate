Once the Litmus Chaos Control plane has been installed and the agent has been installed on cluster, Chaos Experiements need to be run. In Litmus Chaos these experiments can be run by creating kube manifests and running them against the Applications Pods or Cluster Nodes. 

LitmusChaos Agents installs some CRD's along with it which are used to create, run and assess the result of Chaos Experiments. The CRD's and their brief description is as listed below :
  1. ChaosEngine
  2. ChaosExperiment
  3. ChaosResult
  4. Argo WorkFlow

Chaos Experiments can be run in one of two ways. By creating ChaosEngine and ChaosExperiment manifests and creating those Custom Resources into the targeted namespace. The second way would be to create an Argo Workflow custom resource object to run the Chaos Experiments as tasks inside the workflow. 

ChaosEngine & ChaosExperiments Custom Resources 
------------------------------------------------
LitmusChaos Agent Installation installs the CRD for ChaosEngine and ChaosExperiements. Using these Custom Resources manifests can be created to implement ChaosExperiemnts. 

A typical set of steps would be as below : 

1. Start by annotating the deployment or the namespace against which you need to run the experiment(``litmuschaos.io/chaos="true"``). For example the below command would annotate the **nginx** deployment. 

```
kubectl annotate deploy/nginx litmuschaos.io/chaos="true"
```
2. Create the RBAC objects ( Service Account, Role and RoleBinding) which will be used to create and execute the ChaosExperiments. It can be done by using the below manifest :

```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sockshop-chaos-sa
  namespace: sockshop-production
  labels:
    name: sockshop-chaos-sa
    app.kubernetes.io/part-of: litmus
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: sockshop-chaos-sa
  namespace: sockshop-production
  labels:
    name: sockshop-chaos-sa
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
  name: sockshop-chaos-sa
  namespace: sockshop-production
  labels:
    name: sockshop-chaos-sa
    app.kubernetes.io/part-of: litmus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: sockshop-chaos-sa
subjects:
- kind: ServiceAccount
  name: sockshop-chaos-sa
  namespace: sockshop-production
```
Note down the names of the Objects created , specially the Service Account because this would need to be mentioned in other manifests. You would note that these objects are being created in the Application Namespace so that they would have access to Application resources. 

Also this would be one time activity , and need not be repeated for each experiment. 

3. Once you have created SA , you can then install all the ChaosExperiments (create the Custom Resources) to make sure these are availbale to you in the cluster.The arrangement of Custom Resources is such that **ChaosEngine** object connects **ChaosExperiment** to an **Application** . The **ChaosEngine** object , once it finishes running , also updates the **ChaosResult** object. 

There is a set of pre-defined ChaosExperiments and documentation for these can be found at : https://litmuschaos.github.io/litmus/experiments/categories/contents/ 

All of the Experiments can be installed using the below command 
```
kubectl create -f https://hub.litmuschaos.io/api/chaos/2.3.0?file=charts/generic/experiments.yaml -n <APP_NAMESPACE>
```
Here APP_NAMESPACE would be the namespace when Application is installed ( in this case "sockshop-production").

Once the experiments have been installed , you can use below command to list out all the ChaosExperiemnt and go through the details of a ChaosExperiment.

```
kubectl get ChaosExperiment -n <APP_NAMESPACE>

kubectl describe ChaosExperiment <CHAOS_EXPERIMENT_NAME> -n <APP_NAMESPACE>
```

4. Once all the required Experiments are installed , Create a **ChaosEngine** Object to connect ChaosExperiment with the Application. This manifest would also mention the ServiceAccount Object which we created earlier. 

An example manifest would look like the below, this one runs a *pod-delete* experiment against Carts deployment of sockshop application.  Make sure to run the manifest against the APP_NAMESPACE :
```
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: engine-sockshop-pod-delete
spec:
  engineState: "active"
  annotationCheck: "false"
  appinfo:
    appns: "sockshop-production"
    applabel: "app=carts"
    appkind: "deployment"
  chaosServiceAccount: sockshop-chaos-sa
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
5. Check for any ChaosResult Objects created and their status (Success/Fail). 

```
kubectl get ChaosResult -n <APP_NAMESPACE>

kubectl describe ChaosResult <CHAOS_RESULT_NAME> -n <APP_NAMESPACE>
```
More details can be found at : https://litmuschaos.github.io/litmus/experiments/concepts/chaos-resources/contents/


Argo Workflow Custom Resources
---------------------------------

Another way of running a Chaos Experiment would be by using the Argo Workflow Custom Resource. Argo Workflow Custom Resource allows for defining a set of tasks in a work flow and then executing the tasks in that order. 

ArgoWF CRD is installed as part of Litmus Agent installation . To Create and Execute a ChaosWF below steps need to be performed.

1. Create a manifest for an ArgoWF as the one below :
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: argowf-chaos-sock-shop-resiliency-
  namespace: litmus
  labels:
    subject: "sockshop-production_sock-shop"
spec:
  entrypoint: argowf-chaos
  serviceAccountName: argo-chaos
  securityContext:
    runAsUser: 1000
    runAsNonRoot: true
  arguments:
    parameters:
      - name: adminModeNamespace
        value: "litmus"
      - name: appNamespace
        value: "sockshop-production"
  templates:
    - name: argowf-chaos
      steps:
        #- - name: install-application
        #    template: install-application
        - - name: install-chaos-experiments
            template: install-chaos-experiments
        - - name: load-test
            template: load-test
        - - name: pod-cpu-hog
            template: pod-cpu-hog
        - - name: pod-delete
            template: pod-delete
        - - name: pod-network-loss
            template: pod-network-loss
        - - name: pod-memory-hog
            template: pod-memory-hog
        - - name: disk-fill
            template: disk-fill   
        - - name: revert-chaos
            template: revert-chaos
        #  - name: delete-application
        #    template: delete-application
          - name: delete-loadtest
            template: delete-loadtest

    - name: install-application
      container:
        image: litmuschaos/litmus-app-deployer:latest
        args: ["-namespace=sockshop-production","-typeName=resilient","-operation=apply","-timeout=400", "-app=sock-shop","-scope=cluster"] #for weak provide type flagName as resilient(-typeName=weak)

    - name: install-chaos-experiments
      container:
        image: litmuschaos/k8s:latest
        command: [sh, -c]
        args:
          - "kubectl apply -f https://hub.litmuschaos.io/api/chaos/2.3.0?file=charts/generic/experiments.yaml -n
            {{workflow.parameters.adminModeNamespace}} ; sleep 30"

    - name: pod-cpu-hog
      inputs:
        artifacts:
          - name: pod-cpu-hog
            path: /tmp/chaosengine.yaml
            raw:
              data: |
                apiVersion: litmuschaos.io/v1alpha1
                kind: ChaosEngine
                metadata:
                  name: pod-cpu-hog-chaos
                  namespace: {{workflow.parameters.adminModeNamespace}}
                  labels:
                    context: "{{workflow.parameters.appNamespace}}_carts"
                spec:
                  appinfo:
                    appns: 'sockshop-production'
                    applabel: 'app=carts'
                    appkind: 'deployment'
                  jobCleanUpPolicy: retain
                  engineState: 'active'
                  chaosServiceAccount: litmus-admin
                  experiments:
                    - name: pod-cpu-hog
                      spec:
                        probe:
                        - name: "check-frontend-access-url"
                          type: "httpProbe"
                          httpProbe/inputs:
                            url: "http://front-end.sock-shop.svc.cluster.local:80"
                            insecureSkipVerify: false
                            responseTimeout: 100
                            method:
                              get:
                                criteria: "=="
                                responseCode: "200"
                          mode: "Continuous"
                          runProperties:
                            probeTimeout: 2
                            interval: 1
                            retry: 2
                            probePollingInterval: 1
                        - name: "check-benchmark"
                          type: "cmdProbe"
                          cmdProbe/inputs:
                            command: "curl http://qps-test.sock-shop.svc.cluster.local"
                            comparator:
                              type: "int" # supports: string, int, float
                              criteria: ">=" #supports >=,<=,>,<,==,!= for int and contains,equal,notEqual,matches,notMatches for string values
                              value: "100"
                          mode: "Edge"
                          runProperties:
                            probeTimeout: 2
                            interval: 1
                            retry: 2
                            initialDelaySeconds: 10
                        components:
                          env:
                            #number of cpu cores to be consumed
                            #verify the resources the app has been launched with
                            - name: CPU_CORES
                              value: '1'
                            - name: TOTAL_CHAOS_DURATION
                              value: '30' # in seconds
                            - name: CHAOS_KILL_COMMAND
                              value: "kill -9 $(ps afx | grep \"[md5sum] /dev/zero\" | awk '{print$1}' | tr '\n' ' ')"
        
      container:
        image: litmuschaos/litmus-checker:latest
        args: ["-file=/tmp/chaosengine.yaml","-saveName=/tmp/engine-name"]

    - name: pod-memory-hog
      inputs:
        artifacts:
          - name: pod-memory-hog
            path: /tmp/chaosengine.yaml
            raw:
              data: |
                apiVersion: litmuschaos.io/v1alpha1
                kind: ChaosEngine
                metadata:
                  name: pod-memory-hog-chaos
                  namespace: {{workflow.parameters.adminModeNamespace}}
                  labels:
                    context: "{{workflow.parameters.appNamespace}}_orders"
                spec:
                  appinfo:
                    appns: 'sockshop-production'
                    applabel: 'app=orders'
                    appkind: 'deployment'
                  jobCleanUpPolicy: retain
                  engineState: 'active'
                  chaosServiceAccount: litmus-admin
                  experiments:
                    - name: pod-memory-hog
                      spec:
                        probe:
                        - name: "check-frontend-access-url"
                          type: "httpProbe"
                          httpProbe/inputs:
                            url: "http://front-end.sock-shop.svc.cluster.local:80"
                            insecureSkipVerify: false
                            responseTimeout: 100
                            method:
                              get:
                                criteria: "=="
                                responseCode: "200"
                          mode: "Continuous"
                          runProperties:
                            probeTimeout: 2
                            interval: 1
                            retry: 2
                            probePollingInterval: 1
                        - name: "check-benchmark"
                          type: "cmdProbe"
                          cmdProbe/inputs:
                            command: "curl http://qps-test.sock-shop.svc.cluster.local"
                            comparator:
                              type: "int" # supports: string, int, float
                              criteria: ">=" #supports >=,<=,>,<,==,!= for int and contains,equal,notEqual,matches,notMatches for string values
                              value: "100"
                          mode: "Edge"
                          runProperties:
                            probeTimeout: 2
                            interval: 1
                            retry: 2
                            initialDelaySeconds: 10
                        components:
                          env:
                            - name: MEMORY_CONSUMPTION
                              value: '500'
                            - name: TOTAL_CHAOS_DURATION
                              value: '30' # in seconds
                            - name: CHAOS_KILL_COMMAND
                              value: "kill -9 $(ps afx | grep \"[dd] if /dev/zero\" | awk '{print $1}' | tr '\n' ' ')"
                            
      container:
        image: litmuschaos/litmus-checker:latest
        args: ["-file=/tmp/chaosengine.yaml","-saveName=/tmp/engine-name"]

    - name: pod-delete
      inputs:
        artifacts:
          - name: pod-delete
            path: /tmp/chaosengine.yaml
            raw:
              data: |
                apiVersion: litmuschaos.io/v1alpha1
                kind: ChaosEngine
                metadata:
                  name: catalogue-pod-delete-chaos
                  namespace: {{workflow.parameters.adminModeNamespace}}
                  labels:
                    context: "{{workflow.parameters.appNamespace}}_catalogue"
                spec:
                  appinfo:
                    appns: 'sockshop-production'
                    applabel: 'app=catalogue'
                    appkind: 'deployment'
                  engineState: 'active'
                  chaosServiceAccount: litmus-admin
                  jobCleanUpPolicy: 'retain'
                  components:
                    runner:
                      imagePullPolicy: Always
                  experiments:
                    - name: pod-delete
                      spec:
                        probe:
                        - name: "check-catalogue-access-url"
                          type: "httpProbe"
                          httpProbe/inputs:
                            url: "http://front-end.sock-shop.svc.cluster.local:80/catalogue"
                            insecureSkipVerify: false
                            responseTimeout: 100
                            method:
                              get:
                                criteria: "=="
                                responseCode: "200"
                          mode: "Continuous"
                          runProperties:
                            probeTimeout: 12
                            interval: 12
                            retry: 3
                            probePollingInterval: 1
                        - name: "check-benchmark"
                          type: "cmdProbe"
                          cmdProbe/inputs:
                            command: "curl http://qps-test.sock-shop.svc.cluster.local"
                            comparator:
                              type: "int" # supports: string, int, float
                              criteria: ">=" #supports >=,<=,>,<,==,!= for int and contains,equal,notEqual,matches,notMatches for string values
                              value: "100"
                          mode: "Edge"
                          runProperties:
                            probeTimeout: 2
                            interval: 1
                            retry: 2
                            initialDelaySeconds: 2
                        components:
                          env:
                            - name: TOTAL_CHAOS_DURATION
                              value: '30'
                            # set chaos interval (in sec) as desired
                            - name: CHAOS_INTERVAL
                              value: '10'
                            # pod failures without '--force' & default terminationGracePeriodSeconds
                            - name: FORCE
                              value: 'false'
      container:
        image: litmuschaos/litmus-checker:latest
        args: ["-file=/tmp/chaosengine.yaml","-saveName=/tmp/engine-name"]        
    
    - name: pod-network-loss
      inputs:
        artifacts:
          - name: pod-network-loss
            path: /tmp/chaosengine.yaml
            raw:
              data: |
                apiVersion: litmuschaos.io/v1alpha1
                kind: ChaosEngine
                metadata:
                  name: pod-network-loss-chaos
                  namespace: {{workflow.parameters.adminModeNamespace}}
                  labels:
                    context: "{{workflow.parameters.appNamespace}}_user-db"
                spec:
                  appinfo:
                    appns: 'sockshop-production'
                    applabel: 'name=user-db'
                    appkind: 'deployment'
                  jobCleanUpPolicy: retain
                  engineState: 'active'
                  chaosServiceAccount: litmus-admin
                  components:
                    runner:
                      imagePullPolicy: Always
                  experiments:
                    - name: pod-network-loss
                      spec:
                        probe:
                        - name: "check-cards-access-url"
                          type: "httpProbe"
                          httpProbe/inputs:
                            url: "http://front-end.sock-shop.svc.cluster.local:80/cards"
                            insecureSkipVerify: false
                            responseTimeout: 100
                            method:
                              get:
                                criteria: "=="
                                responseCode: "200"
                          mode: "Continuous"
                          runProperties:
                            probeTimeout: 12
                            interval: 12
                            retry: 3
                            probePollingInterval: 1
                        - name: "check-benchmark"
                          type: "cmdProbe"
                          cmdProbe/inputs:
                            command: "curl http://qps-test.sock-shop.svc.cluster.local"
                            comparator:
                              type: "int" # supports: string, int, float
                              criteria: ">=" #supports >=,<=,>,<,==,!= for int and contains,equal,notEqual,matches,notMatches for string values
                              value: "100"
                          mode: "Edge"
                          runProperties:
                            probeTimeout: 2
                            interval: 1
                            retry: 2
                            initialDelaySeconds: 2
                        components:
                          env:
                            - name: TOTAL_CHAOS_DURATION
                              value: '30' 
                            - name: NETWORK_INTERFACE
                              value: 'eth0'
                            - name: NETWORK_PACKET_LOSS_PERCENTAGE
                              value: '100'
                            - name: CONTAINER_RUNTIME
                              value: 'docker' 
                            - name: SOCKET_PATH
                              value: '/var/run/docker.sock'                
      container:
        image: litmuschaos/litmus-checker:latest
        args: ["-file=/tmp/chaosengine.yaml","-saveName=/tmp/engine-name"] 

    - name: disk-fill
      inputs:
        artifacts:
          - name: disk-fill
            path: /tmp/chaosengine.yaml
            raw:
              data: |
                apiVersion: litmuschaos.io/v1alpha1
                kind: ChaosEngine
                metadata:
                  name: catalogue-disk-fill
                  namespace: {{workflow.parameters.adminModeNamespace}}
                  labels:
                    context: "{{workflow.parameters.appNamespace}}_catalogue-db"
                spec:
                  appinfo:
                    appns: 'sockshop-production'
                    applabel: 'name=catalogue-db'
                    appkind: 'deployment'
                  engineState: 'active'
                  chaosServiceAccount: litmus-admin
                  jobCleanUpPolicy: 'retain'
                  components:
                    runner:
                      imagePullPolicy: Always
                  experiments:
                    - name: disk-fill
                      spec:
                        probe:
                        - name: "check-catalogue-db-cr-status"
                          type: "k8sProbe"
                          k8sProbe/inputs:
                            group: ""
                            version: "v1"
                            resource: "pods"
                            namespace: "sockshop-production"
                            fieldSelector: "status.phase=Running"
                            labelSelector: "name=catalogue-db"
                            operation: "present"
                          mode: "Continuous"
                          runProperties:
                            probeTimeout: 1
                            interval: 1
                            retry: 1
                            probePollingInterval: 1
                        - name: "check-benchmark"
                          type: "cmdProbe"
                          cmdProbe/inputs:
                            command: "curl http://qps-test.sock-shop.svc.cluster.local:80"
                            comparator:
                              type: "int" # supports: string, int, float
                              criteria: ">=" #supports >=,<=,>,<,==,!= for int and contains,equal,notEqual,matches,notMatches for string values
                              value: "100"
                          mode: "Edge"
                          runProperties:
                            probeTimeout: 2
                            interval: 1
                            retry: 2
                            initialDelaySeconds: 1
                        components:
                          env:
                            - name: FILL_PERCENTAGE
                              value: '100'
                            - name: TARGET_CONTAINER
                              value: ''
                            - name: TOTAL_CHAOS_DURATION
                              value: '30'                            
      container:
        image: litmuschaos/litmus-checker:latest
        args: ["-file=/tmp/chaosengine.yaml","-saveName=/tmp/engine-name"]

    - name: delete-application
      container:
        image: litmuschaos/litmus-app-deployer:latest
        args: ["-namespace=sockshop-production","-typeName=resilient","-operation=delete", "-app=sock-shop"]

    - name: load-test
      container:
        image: litmuschaos/litmus-app-deployer:latest
        args: ["-namespace=loadtest", "-app=loadtest"]

    - name: delete-loadtest
      container:
        image: litmuschaos/litmus-app-deployer:latest
        args: ["-namespace=loadtest","-operation=delete", "-app=loadtest"]    
    
    - name: revert-chaos
      container:
        image: litmuschaos/k8s:latest
        command: [sh, -c]
        args: 
          [ 
            "kubectl delete chaosengine pod-memory-hog-chaos pod-cpu-hog-chaos catalogue-pod-delete-chaos pod-network-loss-chaos -n {{workflow.parameters.adminModeNamespace}}"]
          
```

Here you can see that the workflow contains multiple ChaosEngine steps executing one ChaosExperiment each. There are some other tasks as well for example install the application, install experiment. We can update this manifest to add/remove tasks , configure experiments , configure probes within each experiment etc. 

Once the manifest is completed , Go to LitmusChaos Portal Front end and run the workflow from there . 

Litmus Portal --> Chaos WorkFlows --> Schedule a Work flow --> import the Workflow YAML .

2. Let the workflow run and watch the detailed logs and stats in the portal. We can also schedule these workflows from the backend command line using argo cli , but in that case the logs and stats would not be visible on the LitmusPortal. 

More details on ArgoWF can be found at Argo Documentation page : https://argoproj.github.io/argo-workflows/
