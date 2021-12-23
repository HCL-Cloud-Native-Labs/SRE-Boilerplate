Gremlin Chaos is a SaaS based application , so the control-plane element for your Chaos setup can be found at : https://app.gremlin.com/dashboard
Before you can access the dashboard , you would first need to create an account and define a team. 

To add a VM or a kubernetes cluster into Gremlin Chaos , we need to install Gremlin Agent on the VM/cluster. The details for doing so are as below :

**General steps deploying to Virtual Machine**:

 1. Get credentials - Team ID with secret or certificates
 2. Install Gremlin packages: gremlin and gremlind
 3. Register to the Control Plane

**General steps deploying to Kubernetes**:

1. Get Credentials - Team ID with secret or certificates
2. Create Kubernetes secret
3. Deploy Helm Chart

## Installing to VM (Ubuntu)

1. Add packages needed to install and verify gremlin (already on many systems)
```
sudo apt update && sudo apt install -y apt-transport-https dirmngr
```

2. Add the Gremlin repo
```
echo "deb https://deb.gremlin.com/ release non-free" | sudo tee /etc/apt/sources.list.d/gremlin.list
```

3. Import the GPG key
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9CDB294B29A5B1E2E00C24C022E8EF3461A50EF6
```

4. Install Gremlin client and daemon
```
sudo apt update && sudo apt install -y gremlin gremlind
```

if you need to install to any other linux distribution, more details can be found at : https://www.gremlin.com/docs/infrastructure-layer/installation/ 

## Installing to Kubernetes Cluster
We can install the Kubernetes client using either kubectl or helm. First create a kuernetes secret containing your gremlin certificates.  

1. Download the Gremlin certificates by logging to your account --> Team Settings --> Configuration --> Certificates --> Create New (your role must either be Team Manager or Team Credential Manager).
2. Unzip certificates.zip.
3. Rename the files in the certificates folder. Team Name.pub_cert.pem becomes gremlin.cert. Team Name.priv_key.pem becomes gremlin.key.
4. Create a gremlin namespace:
```
kubectl create namespace gremlin
```
5. Create a kubernetes secret by running the following
```
kubectl -n gremlin create secret generic gremlin-team-cert --from-file=/path/to/gremlin.cert --from-file=/path/to/gremlin.key
```
**Installation using kubectl**
1. Download the Gremlin configuration manifest by running the following
```
wget https://k8s.gremlin.com/resources/gremlin-conf.yaml
```
2. Open the file and update the following:
```
Replace <YOUR TEAM ID GOES HERE> with your Gremlin team ID.
Replace <YOUR TEAM SECRET GOES HERE> with your Gremlin team secret (If you are using certificate-based authentication, remove this line.)
Replace <YOUR UNIQUE CLUSTER NAME GOES HERE> with a unique name for your cluster. This can be any name you want, and will appear in Gremlin in the Kubernetes client list.
```
3. Apply the Kubernetes manifest 
 ```
  kubectl apply -f gremlin-conf.yaml
 ```
**Installation Using Helm**
1. To deploy Gremlin using Helm, first add the Gremlin Helm chart repository:
```
helm repo remove gremlin
helm repo add gremlin https://helm.gremlin.com
```
2. Create three environment variables: one for your Gremlin team ID, another fir your Gremlin secret key, and a third for your Kubernetes cluster name.
```
GREMLIN_TEAM_ID="my_gremlin_team_id"
GREMLIN_CLUSTER_ID="my_cluster_name"
GREMLIN_TEAM_SECRET="my_gremlin_team_secret"
```
3. Deploy the Helm chart
```
helm install gremlin/gremlin \
    --name gremlin \
    --namespace gremlin \
    --set gremlin.secret.managed=true \
    --set gremlin.secret.type=secret \
    --set gremlin.hostPID=true \
    --set gremlin.secret.teamID=$GREMLIN_TEAM_ID \
    --set gremlin.secret.clusterID=$GREMLIN_CLUSTER_ID \
    --set gremlin.secret.teamSecret=$GREMLIN_TEAM_SECRET
```
Once the agent has been installed , you can check the same on your Gremlin dashboard by checking under Active Clients ( Hosts/Kubernetes).
