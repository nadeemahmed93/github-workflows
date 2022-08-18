locals {​​​​​​​
  role_based_access_control_enabled = var.rbac_client_id != null && var.rbac_server_id != null && var.rbac_server_secret != null && var.rbac_tenant_id != null
  rbac_config = local.role_based_access_control_enabled ? [{​​​​​​​
    rbac_client_id : var.rbac_client_id,
    rbac_server_id : var.rbac_server_id,
    rbac_server_secret : var.rbac_server_secret
    rbac_tenant_id : var.rbac_tenant_id
  }​​​​​​​] : []
  standard_tags = {​​​​​​​
    environment      = var.environment
    application-name = var.tag_app_name
    cost-center      = var.tag_cost_center
    owner            = var.tag_owner
  }​​​​​​​
}​​​​​​​
 
