
Thanos installation is done using the bitnami chart : https://github.com/bitnami/charts/tree/master/bitnami/thanos/ 

Thanos is setup on SRE-K8s-CNL cluster in Noida. 3 Node Cluster , Native K8S, servers are sremaster, srenode1, srenode2.  

To install the chart :

``
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install thanos bitnami/thanos -n monitoring
``

