variable "az_subscription_id" {​​​​​​​}​​​​​​​


variable "service_principal_client_id" {​​​​​​​}​​​​​​​


variable "az_resource_group" {​​​​​​​
  description = "Name of existing resrouce group"
}​​​​​​​


variable "tenant_id" {​​​​​​​}​​​​​​​


variable "vnet_resource_group" {​​​​​​​
  description = "The resource group that contains the vNET"
}​​​​​​​


variable "vnet_name" {​​​​​​​
  description = "The name of an existing vNET"
}​​​​​​​


variable "subnet_name" {​​​​​​​
  description = "The name of the existing subnet to use"
}​​​​​​​


variable "az_firewall" {​​​​​​​
  description = "The IP address of the Azure firewall for the vNet"
}​​​​​​​


variable "tag_app_name" {​​​​​​​
  description = "The name or GUID of the application as defined in "
}​​​​​​​


variable "tag_cost_center" {​​​​​​​
  description = "The internal cost center for show/charge back billing"
}​​​​​​​


variable "tag_owner" {​​​​​​​
  description = "The team or person that owns the resources"
}​​​​​​​


variable "kubernetes_version" {​​​​​​​
  description = "Version of Kubernetes to install"
  default     = "1.15.10"
}​​​​​​​


variable "application_name" {​​​​​​​
  description = "Application name"
  default     = "my-app"
}​​​​​​​


variable "environment" {​​​​​​​
  description = "Lowercase name of environment/lifecycle, such as sandbox, dev, test, stage, or prod"
  default     = "sandbox"
}​​​​​​​


variable "rbac_client_id" {​​​​​​​
  type        = string
  default     = null
  description = "The Client ID of an Azure Active Directory Application."
}​​​​​​​


variable "rbac_server_id" {​​​​​​​
  type        = string
  default     = null
  description = "The Server ID of an Azure Active Directory Application."
}​​​​​​​


variable "rbac_tenant_id" {​​​​​​​
  type        = string
  default     = null
  description = "The Tenant ID of the Azure Active Directory Application."
}​​​​​​​


variable "service_principal_client_secret" {​​​​​​​}​​​​​​​


variable "rbac_server_secret" {​​​​​​​
  type        = string
  default     = null
  description = "The Server Secret of an Azure Active Directory Application."
}​​​​​​​


variable "dns_prefix" {​​​​​​​
  default = ""
}​​​​​​​


variable "enable_auto_scaling" {​​​​​​​
  default = true
}​​​​​​​


variable "node_pool_vm_size" {​​​​​​​
  description = "The size of the VMs to use in the node pool"
  default     = "Standard_D8s_v3"
}​​​​​​​


variable "node_pool_min_instances" {​​​​​​​
  description = "minimum number of nodes which should exist in this Node Pool"
  default     = 3
}​​​​​​​


variable "node_pool_max_instances" {​​​​​​​
  description = "maximum number of nodes which should exist in this Node Pool"
  default     = 10
}​​​​​​​


variable "node_pool_inital_instances" {​​​​​​​
  description = "initial number of nodes which should exist in this Node Pool must be between min and max"
  default     = 3
}​​​​​​​


variable "node_pool_os_disk_size" {​​​​​​​
  description = "The size of the OS disk in GB"
  default     = 50
}​​​​​​​


variable "admin_user" {​​​​​​​
  description = "The admin user on the nodes"
  default     = "ubuntu"
}​​​​​​​
 




























