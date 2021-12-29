For collection of Distributed tracing from applications hosted on Kubernetes clusters , we need to have install Istio Service Mesh along with the Jaeger add on. Istio Service Mesh comes with a envoy proxy sidecar which is injected into each of the pods and collects the traces ( along with other telemetry data). The Jaerger add on installs a trace collector along with a WebUI which collects and visualizes the traces. 

The jaeger service can then be added to Grafana as a data source so that the traces can be used for visualization in dashboards and extracting metrics related to Application Performance Management. 

Installation of Istio :
------------------------
Istio comes with many installation options (https://istio.io/latest/docs/setup/install/) , but here we would be listing the steps for installing istio with the command line utility *istioctl* (This is the method we have used). 

**Install with Istioctl**
**Prerequisites** :
1. Download the latest istio release. 
```
curl -L https://istio.io/downloadIstio | sh -
```
2.Move to the Istio package directory. For example, if the package is istio-1.12.1:
```
 cd istio-1.12.1 
```
The installation directory contains:
  . Sample applications in samples/
  . The istioctl client binary in the bin/ directory
  
3. Add the istioctl client to your path (Linux or macOS):
```
export PATH=$PWD/bin:$PATH 
```
4. Install istio with *demo* profile using the _istioctl_ command as below :
```
istioctl install --set profile=demo -y
```
output should be something similar to below :
```
istioctl install --set profile=demo -y
✔ Istio core installed
✔ Istiod installed
✔ Egress gateways installed
✔ Ingress gateways installed
✔ Installation complete
```
also we should be able to see the pods,services etc. for istio-control plane inside the *istio-system* namespace. 
```
kubectl get all -n istio-system
```

5. Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later. This should be the namespace where the application is installed. You can label multiple namespaces if needed. 
```
kubectl label namespace default istio-injection=enabled
```

6. Restart the deployment , rollout deployment in your namespace 
```
kubectl rollout restart deployment -n YOUR_NAMESPACE
```
7. Now watch the pods coming back up and see if you can see the envoy proxy sidecar in the each of the pods :
```
watch kubectl get pods -n YOU_NAMESPACE
kubectl describe pod POD_NAME
```

**Installing Jaeger Add On**

1. To install the jaeger add on , use the below command :
```
kubectl apply -f samples/addons/jaeger
kubectl rollout status deployment/jaeger -n istio-system
```
2. Once the deployment status is running, check the pods in the istio-system namespace
```
kubectl get pods, svc -n istio-system
```
3. Expose the jaeger pod to access the jaeger UI :
```
kubectl expose deployment/jaeger -n istio-system
```
