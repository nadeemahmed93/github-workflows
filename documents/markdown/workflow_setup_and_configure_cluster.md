## WorkFlow :  Set-up and configure kubernetes(K8s) cluster


This workflow is responsible for configuring initial setup of kubernetes cluster. The workflow file is present in `.github/workflow/` directory with name `setup-k8s-cluster.yml`.
This involves setting up of:


- [Namespaces in K8s](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Role Based Access Control(RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Nginx Ingress Controller](https://www.nginx.com/products/nginx-ingress-controller)
- [Dynatrace One Agent Operator](https://www.dynatrace.com/support/help/technology-support/cloud-platforms/kubernetes/deploy-oneagent-k8/)


## Understanding the Workflow file
    
This section explains each line of the workflow file:


### workflow_dispatch
workflows are manually triggered with the new `workflow_dispatch` event.
You will then see a `Run workflow` button on the `Actions` tab, enabling you to easily trigger a run.


```yaml
# Manually triggered
on: workflow_dispatch
```


### env
This sets custom environment variables that are available to every step in a workflow run.
Environment variables are case-sensitive. Commands run in actions or steps can create, read, and modify environment variables.


### Jobs
Here we are running **create_k8s_resources** and **deploy_cluster_charts** jobs in self-hosted runners.
>> Job **deploy_cluster_charts** will run only if **create_k8s_resources** completes successfully.


```yaml
jobs:
  create_k8s_resources:
    runs-on: self-hosted
    ....
    ....
    ....
  deploy_cluster_charts:
    needs: create_k8s_resources
    runs-on: self-hosted
```


#### Overview of steps in **`create_k8s_resources`** job


<table>
<tr>
<th>
Description
</th>
<th>
Steps
</th>
</tr>


<tr>
<td>


Checkout the repository to the GitHub Actions runner
</td>
<td>


```yaml
- name: Checkout
  uses: actions/checkout@v2
```


</td>
</tr>


<tr>
<td>


Sets the AKS context with credentials


</td>
<td>


```yaml
- name: Setting AKS set context  
  uses: azure/aks-set-context@v1
  with:
    creds: ${​​​​​​​{​​​​​​​ secrets.AZURE_DEPLOY_CREDENTIALS }​​​​​​​}​​​​​​​
    resource-group: ${​​​​​​​{​​​​​​​ env.RESOURCE_GROUP }​​​​​​​}​​​​​​​
    cluster-name: ${​​​​​​​{​​​​​​​ env.CLUSTER_NAME }​​​​​​​}​​​​​​​
```


</td>
</tr>


<tr>
<td>


Login to Azure with the appropriate credentials


</td>
<td>


```yaml
- name: Login
  uses: Azure/login@v1
  with:
    creds: ${​​​​​​​{​​​​​​​ secrets.AZURE_DEPLOY_CREDENTIALS }​​​​​​​}​​​​​​​ 
```


</td>


</tr>



<tr>
<td>


Create namespaces


</td>
<td>


```yaml
- name: Create namespaces
  run: |
    kubectl apply -f ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/k8s/namespaces/-namespace.yaml
    kubectl apply -f ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/k8s/namespaces/ingress-nginx-namespace.yaml
    kubectl apply -f ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/k8s/namespaces/dynatrace-namespace.yaml
```


</td>
</tr>


<tr>
<td>


Download TLS Certificate and Key from Keyvault


</td>
<td>


```yaml
- name: Download TLS Certificate and key
  run: |
    az keyvault secret download \
    --name ${​​​​​​​{​​​​​​​ env.ACR_CERTIFICATE_NAME }​​​​​​​}​​​​​​​ \
    --vault-name ${​​​​​​​{​​​​​​​ env.KEYVAULT_NAME }​​​​​​​}​​​​​​​ \
    -f certificate.crt
    az keyvault secret download \
    --name ${​​​​​​​{​​​​​​​ env.ACR_PRIVATEKEY_NAME }​​​​​​​}​​​​​​​ \
    --vault-name ${​​​​​​​{​​​​​​​ env.KEYVAULT_NAME }​​​​​​​}​​​​​​​ \
    -f privatekey.key
```


</td>


</tr>


<tr>
<td>


Create TLS secret for Ingress


</td>
<td>


```yaml
- name: Create TLS Secret
  run: |
    kubectl delete secret ${​​​​​​​{​​​​​​​ env.TLS_SECRET_NAME }​​​​​​​}​​​​​​​ \
    --ignore-not-found -n ${​​​​​​​{​​​​​​​ env.INGRESS_NAMESPACE }​​​​​​​}​​​​​​​
    kubectl create secret tls ${​​​​​​​{​​​​​​​ env.TLS_SECRET_NAME }​​​​​​​}​​​​​​​ \
    --cert=certificate.crt --key=privatekey.key -n ${​​​​​​​{​​​​​​​ env.INGRESS_NAMESPACE }​​​​​​​}​​​​​​​
```


</td>


</tr>



<tr>
<td>


Create ImagePullSecret


</td>
<td>


```yaml
- name: Create ImagePullSecret
  uses: azure/k8s-create-secret@v1
  with:
    namespace: ${​​​​​​​{​​​​​​​ env.NAMESPACE }​​​​​​​}​​​​​​​
    container-registry-url: ${​​​​​​​{​​​​​​​ env.REGISTRY_NAME }​​​​​​​}​​​​​​​.azurecr.io
    container-registry-username: ${​​​​​​​{​​​​​​​ env.REGISTRY_USERNAME }​​​​​​​}​​​​​​​
    container-registry-password: ${​​​​​​​{​​​​​​​ secrets.SERVICE_PRINCIPAL_CLIENT_SECRET }​​​​​​​}​​​​​​​
    secret-name: ${​​​​​​​{​​​​​​​ env.IMAGEPULL_SECET_NAME }​​​​​​​}​​​​​​​
```


</td>


</tr>


<tr>
<td>


Create ingress resource


</td>
<td>


```yaml
- name: Create Ingress resource
  run: kubectl apply -f ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/k8s/ingress/ingress.yaml
```


</td>


</tr>


<tr>
<td>


Create rolebindings for dev and admin access through RBAC


</td>
<td>


```yaml
- name: Create rolebindings for AAD/RBAC
  run: |
    kubectl apply -f ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/k8s/roles/role-bindings/admin-azure-ad-binding.yaml
    kubectl apply -f ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/k8s/roles/role-bindings/dev-azure-ad-binding.yaml
```


</td>


</tr>


</table>



#### Overview of steps in **`deploy_cluster_charts`** job


<table>
<tr>
<th>
Description
</th>
<th>
Steps
</th>
</tr>


<tr>
<td>
Sets the AKS context with credentials
</td>
<td>


```yaml
- name: Setting AKS set context  
  uses: azure/aks-set-context@v1
  with:
    creds: ${​​​​​​​{​​​​​​​ secrets.AZURE_DEPLOY_CREDENTIALS }​​​​​​​}​​​​​​​
    resource-group: ${​​​​​​​{​​​​​​​ env.RESOURCE_GROUP }​​​​​​​}​​​​​​​
    cluster-name: ${​​​​​​​{​​​​​​​ env.CLUSTER_NAME }​​​​​​​}​​​​​​​
```


</td>
</tr>


<tr>
<td>


Setup Helm


</td>
<td>


```yaml
- name: Install Helm
  uses: azure/setup-helm@v1
  with:
    version: ${​​​​​​​{​​​​​​​ env.HELM_VERSION }​​​​​​​}​​​​​​​
```


</td>


</tr>


<tr>
<td>


Install Nginx Ingress Controller


</td>
<td>
 
 ```yaml
- name: Install nginx ingress controller
  run: |
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm upgrade --install nginx-ingress-controller ingress-nginx/ingress-nginx \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"=true \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.service.loadBalancerIP="10.32.223.7" \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --version 3.8.0 --namespace ${​​​​​​​{​​​​​​​ env.INGRESS_NAMESPACE }​​​​​​​}​​​​​​​
```


</td>


</tr>


<tr>


<td>


Install DynatraceOne Agent Operator


</td>
<td>


```yaml
- name: Install Dynatrace
  run: |
    helm repo add dynatrace https://raw.githubusercontent.com/Dynatrace/helm-charts/master/repos/stable
    helm upgrade --install \
    dynatrace-oneagent-operator dynatrace/dynatrace-oneagent-operator \
    --set secret.apiToken=${​​​​​​​{​​​​​​​ secrets.DYNATRACE_API_TOKEN }​​​​​​​}​​​​​​​ \
    --set secret.paasToken=${​​​​​​​{​​​​​​​ secrets.DYNATRACE_PAAS_TOKEN }​​​​​​​}​​​​​​​ \
    --namespace ${​​​​​​​{​​​​​​​ env.DYNATRACE_NAMESPACE }​​​​​​​}​​​​​​​ --values ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/charts/dynatrace/values.yaml \
    --version 0.8.2
```


</td>
</tr>


</table>
 























































































