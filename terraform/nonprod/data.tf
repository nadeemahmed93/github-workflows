## Resource Group was created outside of this scope
data "azurerm_resource_group" "group" {​​​​​​​
  name = var.az_resource_group
}​​​​​​​


data "azurerm_virtual_network" "nonprod" {​​​​​​​
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}​​​​​​​


data "azurerm_policy_set_definition" "pod_security_baseline_standards" {​​​​​​​
  display_name = "Kubernetes cluster pod security baseline standards for Linux-based workloads"
}​​​​​​​


data "azurerm_client_config" "current" {​​​​​​​}​​​​​​​
 





