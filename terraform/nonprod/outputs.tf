output "cluster" {​​​​​​​
  value = "az aks get-credentials -g ${​​​​​​​var.az_resource_group}​​​​​​​ --subscription ${​​​​​​​var.az_subscription_id}​​​​​​​ --name ${​​​​​​​azurerm_kubernetes_cluster.cluster.name}​​​​​​​"
}​​​​​​​
 
