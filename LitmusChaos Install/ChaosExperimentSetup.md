Once the Litmus Chaos Control plane has been installed and the agent has been installed on cluster, Chaos Experiements need to be run. In Litmus Chaos these experiments can be run by creating kube manifests and running them against the Applications Pods or Cluster Nodes. 

LitmusChaos Agents installs some CRD's along with it which are used to create, run and assess the result of Chaos Experiments. The CRD's and their brief description is as listed below :
  1. ChaosEngine
  2. ChaosExperiment
  3. ChaosResult
  4. Argo WorkFlow

Chaos Experiments can be run in one of two ways. By creating ChaosEngine and ChaosExperiment manifests and creating those Custom Resources into the targeted namespace. The second way would be to create an Argo Workflow custom resource object to run the Chaos Experiments as tasks inside the workflow. 

ChaosEngine & ChaosExperiments Custom Resources 
------------------------------------------------



Argo Workflow Custom Resources
---------------------------------
