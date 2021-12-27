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

Additionally you can verify the installation by listing all the pods in the Gremlin namespace. The output for list of pods and services should looks like below : 

list of pods 
<Insert-details-here-from-cluster>
list of svc
<Insert-details-svc>
 
**Additional Steps for installing on OpenShift** 
In SRE Lab we have setup the Gremlin agent on an OpenShift Cluster and there are some more steps that we need to do for the installation on OpenShift.
**Install Gremlin SELinux policy**
As Openshift uses SELinux, Gremlin requires a custom SELinux policy to grant the minimal permissions needed. You can install either Using SSH, or Using Gremlin Machine Config Operator as available at github repo : https://github.com/gremlin/field-solutions/tree/main/gremlin-ocp4-mc 
 
We have used the Gremlin Machine Config Operator , but you can use either of the methods as listed below :

**Using SSH**
On every OpenShift node, run the following command to install the SELinux module
```
curl -fsSL https://github.com/gremlin/selinux-policies/releases/download/v0.0.3/selinux-policies-v0.0.3.tar.gz -o selinux-policies-v0.0.3.tar.gz
tar xzf selinux-policies-v0.0.3.tar.gz
sudo semodule -i selinux-policies-v0.0.3/gremlin-openshift4.cil
```
 
**Using Gremlin Machine Config Operator**
Above process of installing the SElinux policy using SSH can be repetitive if the cluster contains a large number of nodes and hence the method of using the operator is recommeded in Production OpenShift cluster. 

 Gremlin provides an open-source Machine Config Operator (MCO) for installing the Gremlin SELinux policy to Worker nodes using the Openshift 4 Command-Line Interface (CLI). The MCO files and instructions are available from the Gremlin Field Solutions GitHub repository : https://github.com/gremlin/field-solutions/tree/main/gremlin-ocp4-mc
 
Clone the above repo, and take the config yaml file from the repo as per your OpenShift version number ( for 4.1 to 4.5 OC cluster its 95-worker-gremlin-semodule.yaml, for OC 4.6+ it is 96-worker-gremlin-semodule.yaml). 
 
You would need to modify the above files to modify te below fields :

 machineconfiguration.openshift.io/role: worker # change to master if you are changing master nodes
 spec.config.storage.contents.source :  modify the contents of this field with the base64 encoded config generated in next step. 
 

**Generate the base 64 config** This is done as a straight cut and paste of the results of the following commands, so based on where you want to generate the config file , run the following command there:

``RHEL: base64 selinux-policies-v0.0.2/gremlin-openshift4.cil -w0 > gremlin-openshift4.cil.b64``

``MacOS: base64 selinux-policies-v0.0.2/gremlin-openshift4.cil -o gremlin-openshift4.cil.b64``

(You may need to use set maxmempattern=2000000 or something in your .vimrc file) You can also try using :r gremlin-openshift4.cil.b64 at the correct spot in the file. Make sure it is on the correct line and there is no space!

To apply to Openshift 4.1 - 4.5 cluster:

``oc create -f 95-worker-gremlin-semodule.yaml``

To apply to Openshift 4.6+ cluster:

``oc create -f 96-worker-gremlin-semodule.yaml``

You can now run the installation of Gremlin agent as detailed earlier in this manual.
