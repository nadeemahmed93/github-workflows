resource "azurerm_subnet" "kubernetes_cluster" {​​​​​​​
  name                                           = ""
  resource_group_name                            = var.vnet_resource_group
  virtual_network_name                           = var.vnet_name
  address_prefixes                               = ["10.*.*.*/*"]
  enforce_private_link_endpoint_network_policies = true


  service_endpoints = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
  ]


}​​​​​​​


resource "azurerm_route_table" "kubernetes_cluster" {​​​​​​​
  name                = "route-aks-${​​​​​​​data.azurerm_resource_group.group.location}​​​​​​​"
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
}​​​​​​​


resource "azurerm_route" "default" {​​​​​​​
  address_prefix         = "0.0.0.0/0"
  name                   = "route-default"
  next_hop_in_ip_address = var.az_firewall
  next_hop_type          = "VirtualAppliance"
  resource_group_name    = data.azurerm_resource_group.group.name
  route_table_name       = azurerm_route_table.kubernetes_cluster.name
}​​​​​​​


resource "azurerm_subnet_route_table_association" "aks_subnet_association" {​​​​​​​
  subnet_id      = azurerm_subnet.kubernetes_cluster.id
  route_table_id = azurerm_route_table.kubernetes_cluster.id
}​​​​​​​


resource "azurerm_log_analytics_workspace" "log_workspace" {​​​​​​​
  name                = "log-aks-${​​​​​​​data.azurerm_resource_group.group.location}​​​​​​​-aks"
  resource_group_name = data.azurerm_resource_group.group.name
  location            = data.azurerm_resource_group.group.location
  sku                 = "PerGB2018"
  tags                = local.standard_tags
}​​​​​​​


resource "azurerm_monitor_diagnostic_setting" "kubernetes_cluster" {​​​​​​​
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
  name                       = azurerm_log_analytics_workspace.log_workspace.name
  target_resource_id         = azurerm_kubernetes_cluster.cluster.id


  dynamic "log" {​​​​​​​
    for_each = [
      "cluster-autoscaler",
      "guard",
      "kube-apiserver",
      "kube-audit-admin",
      "kube-audit",
      "kube-controller-manager",
      "kube-scheduler",
    ]


    content {​​​​​​​
      category = log.value


      retention_policy {​​​​​​​
        days    = 0
        enabled = false
      }​​​​​​​
    }​​​​​​​
  }​​​​​​​


  metric {​​​​​​​
    category = "AllMetrics"
    enabled  = false


    retention_policy {​​​​​​​
      days    = 0
      enabled = false
    }​​​​​​​
  }​​​​​​​
}​​​​​​​


resource "azurerm_log_analytics_solution" "log_solution" {​​​​​​​
  solution_name         = "ContainerInsights"
  resource_group_name   = data.azurerm_resource_group.group.name
  location              = data.azurerm_resource_group.group.location
  workspace_resource_id = azurerm_log_analytics_workspace.log_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_workspace.name


  plan {​​​​​​​
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }​​​​​​​
}​​​​​​​


resource "azurerm_key_vault" "kubernetes_cluster" {​​​​​​​
  name                = "nonprod-vault"
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id


  sku_name = "standard"


  soft_delete_enabled        = true
  soft_delete_retention_days = 90
  purge_protection_enabled   = false


  access_policy {​​​​​​​
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id


    secret_permissions = [
      "get",
      "set",
      "list",
    ]
  }​​​​​​​
}​​​​​​​


resource "azurerm_kubernetes_cluster" "cluster" {​​​​​​​
  name                = "${​​​​​​​var.application_name}​​​​​​​-${​​​​​​​var.environment}​​​​​​​-aks"
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = var.dns_prefix != "" ? var.dns_prefix : "${​​​​​​​var.application_name}​​​​​​​-${​​​​​​​var.environment}​​​​​​​"


  default_node_pool {​​​​​​​
    name                = "default"
    availability_zones  = ["1", "2", "3"]
    type                = "VirtualMachineScaleSets"
    node_count          = var.node_pool_inital_instances
    min_count           = var.node_pool_min_instances
    max_count           = var.node_pool_max_instances
    vm_size             = var.node_pool_vm_size
    os_disk_size_gb     = var.node_pool_os_disk_size
    vnet_subnet_id      = azurerm_subnet.kubernetes_cluster.id
    enable_auto_scaling = var.enable_auto_scaling
  }​​​​​​​


  network_profile {​​​​​​​
    network_plugin     = "kubenet"
    service_cidr       = "192.168.64.0/18"
    dns_service_ip     = "192.168.64.10"
    docker_bridge_cidr = "192.168.128.1/18"
    pod_cidr           = "192.168.0.0/18"
  }​​​​​​​


  service_principal {​​​​​​​
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }​​​​​​​


  dynamic "role_based_access_control" {​​​​​​​
    for_each = local.rbac_config
    content {​​​​​​​
      enabled = local.role_based_access_control_enabled
      azure_active_directory {​​​​​​​
        client_app_id     = role_based_access_control.value["rbac_client_id"]
        server_app_id     = role_based_access_control.value["rbac_server_id"]
        server_app_secret = role_based_access_control.value["rbac_server_secret"]
        tenant_id         = role_based_access_control.value["rbac_tenant_id"]
      }​​​​​​​
    }​​​​​​​
  }​​​​​​​


  addon_profile {​​​​​​​
    oms_agent {​​​​​​​
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
    }​​​​​​​


    kube_dashboard {​​​​​​​
      enabled = true
    }​​​​​​​


    azure_policy {​​​​​​​
      enabled = true
    }​​​​​​​
  }​​​​​​​


  tags = data.azurerm_resource_group.group.tags


  # If the subnet that we provide to the cluster is already associated with a
  #   route table, then the cluster will use that route table. But if there's
  #   no route table association, the cluster will create a route table of its
  #   own in the managed cluster resource group and associate it with the
  #   subnet that was provided. This creates a race condition because there's
  #   no implicit dependency that can be inferred between the cluster and its
  #   subnet's route table. To avoid this potential deadlock, we explicitly
  #   define that cluster/route table dependency here.
  depends_on = [
    azurerm_subnet_route_table_association.aks_subnet_association
  ]


  lifecycle {​​​​​​​
    ignore_changes = [
      # Ignore node count changes to because of AutoScaling
      default_node_pool[0].node_count
    ]
  }​​​​​​​
}​​​​​​​


resource "random_uuid" "pod_security_baseline_standards" {​​​​​​​
  keepers = {​​​​​​​
    scope = azurerm_kubernetes_cluster.cluster.id
  }​​​​​​​
}​​​​​​​


resource "azurerm_policy_assignment" "pod_security_baseline_standards" {​​​​​​​
  name                 = random_uuid.pod_security_baseline_standards.result
  policy_definition_id = data.azurerm_policy_set_definition.pod_security_baseline_standards.id
  scope                = random_uuid.pod_security_baseline_standards.keepers.scope
}​​​​​​​


resource "azurerm_container_registry" "acr" {​​​​​​​
  name                = "acrnonprod"
  resource_group_name = data.azurerm_resource_group.group.name
  location            = data.azurerm_resource_group.group.location
  sku                 = "Premium"
  admin_enabled       = false
}​​​​​​​
 



































