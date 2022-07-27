resource "random_string" "random_string" {
  length = 5
  special = false
  lower = true
  upper = false
  numeric = true
}

resource "azurerm_resource_group" "rg_secondary" {
  name = var.resource_group_name_secondary
  location = var.location_secondary
  tags = var.tags
}

resource "azurerm_recovery_services_vault" "asr_vault" {
  name                = "${var.asr_vault_name}"
  location            = var.location_secondary
  resource_group_name = azurerm_resource_group.rg_secondary.name
  sku                 = "Standard"

  identity {
    type              = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_site_recovery_fabric" "primary" {
  name                = "primary-fabric"
  resource_group_name = azurerm_resource_group.rg_secondary.name
  recovery_vault_name = azurerm_recovery_services_vault.asr_vault.name
  location            = var.location_primary
}

resource "azurerm_site_recovery_fabric" "secondary" {
  name                = "secondary-fabric"
  resource_group_name = azurerm_resource_group.rg_secondary.name
  recovery_vault_name = azurerm_recovery_services_vault.asr_vault.name
  location            = var.location_secondary
}

resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = "primary-protection-container"
  resource_group_name  = azurerm_resource_group.rg_secondary.name
  recovery_vault_name  = azurerm_recovery_services_vault.asr_vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  name                 = "secondary-protection-container"
  resource_group_name  = azurerm_resource_group.rg_secondary.name
  recovery_vault_name  = azurerm_recovery_services_vault.asr_vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}

resource "azurerm_site_recovery_replication_policy" "policy" {
  name                                                 = "replication-policy"
  resource_group_name                                  = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.asr_vault.name
  recovery_point_retention_in_minutes                  = var.recovery_point_retention_minutes
  application_consistent_snapshot_frequency_in_minutes = var.app_consistent_snapshot_frequency_minutes
}

resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                       = azurerm_recovery_services_vault.asr_vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  tags                                      = var.tags
}

resource "azurerm_site_recovery_network_mapping" "network-mapping" {
  name                        = "network-mapping"
  resource_group_name         = azurerm_resource_group.rg_secondary.name
  recovery_vault_name         = azurerm_recovery_services_vault.asr_vault.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
  source_network_id           = var.existing_vnet_id_primary
  target_network_id           = azurerm_virtual_network.secondary.id
}

resource "azurerm_storage_account" "primary" {
  name                                    = "asrrecoverycache${random_string.random_string.result}"
  location                                = var.location_primary
  resource_group_name                     = var.asr_cache_resource_group_name
  account_tier                            = "Standard"
  account_replication_type                = "LRS"
  min_tls_version                         = "TLS1_2"
  enable_https_traffic_only               = true 
  tags                                    = var.tags

  network_rules {
    default_action              = "Deny"
    bypass                      = ["AzureServices"]
    virtual_network_subnet_ids  = [var.existing_subnet_id]
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10  
    }
    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }
}

resource "azurerm_role_assignment" "asr_contributor_assignment" {
  scope                     = azurerm_storage_account.primary.id
  role_definition_name      = "Contributor"
  principal_id              = azurerm_recovery_services_vault.asr_vault.identity[0].principal_id

  depends_on = [azurerm_storage_account.primary]
}

resource "azurerm_role_assignment" "asr_storageblobdatacontributor_assignment" {
  scope                     = azurerm_storage_account.primary.id
  role_definition_name      = "Storage Blob Data Contributor"
  principal_id              = azurerm_recovery_services_vault.asr_vault.identity[0].principal_id
  depends_on = [azurerm_storage_account.primary]
}

resource "azurerm_virtual_network" "secondary" {
  name                = "asr-network"
  resource_group_name = azurerm_resource_group.rg_secondary.name
  address_space       = var.asr_vnet_address_space
  location            = azurerm_resource_group.rg_secondary.location
  tags = var.tags
}

resource "azurerm_subnet" "secondary" {
  name                 = "asr-subnet"
  resource_group_name  = azurerm_resource_group.rg_secondary.name
  virtual_network_name = azurerm_virtual_network.secondary.name
  address_prefixes     = var.asr_subnet_prefixes
}

resource "azurerm_public_ip" "secondary" {
  for_each            = {for i, v in var.existing_vm_primary : i => v if v.vm_pubip}
  name                = "${each.value.vm_name}-asr-pubip"
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg_secondary.location
  resource_group_name = azurerm_resource_group.rg_secondary.name
  sku                 = "Basic"
  tags                = var.tags
}

resource "azurerm_site_recovery_replicated_vm" "vm-replication-pubip" {
  for_each                                  = {for i, v in var.existing_vm_primary : i => v if v.vm_pubip}
  name                                      = "${each.value.vm_name}-asr-replica"
  resource_group_name                       = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                       = azurerm_recovery_services_vault.asr_vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary.name
  source_vm_id                              = each.value.vm_id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary.name

  target_resource_group_id                = azurerm_resource_group.rg_secondary.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary.id

  managed_disk {
    disk_id                    = each.value.vm_osdisk_id
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = azurerm_resource_group.rg_secondary.id
    target_disk_type           = each.value.vm_osdisk_type
    target_replica_disk_type   = each.value.vm_osdisk_type
  }

  dynamic "managed_disk" {
    for_each                   = each.value.vm_datadisks !=null ? each.value.vm_datadisks : []
    content{
    disk_id                    = managed_disk.value["id"]
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = azurerm_resource_group.rg_secondary.id
    target_disk_type           = managed_disk.value["type"]
    target_replica_disk_type   = managed_disk.value["type"]
    }
  }
  
  network_interface {
      source_network_interface_id   = each.value.vm_existing_nic_id
      target_subnet_name            = azurerm_subnet.secondary.name
      recovery_public_ip_address_id = azurerm_public_ip.secondary[each.key].id
  }

  tags = var.tags

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.container-mapping,
    azurerm_site_recovery_network_mapping.network-mapping,
  ]
}
resource "azurerm_site_recovery_replicated_vm" "vm-replication-no-pubip" {
  for_each                                  = {for i, v in var.existing_vm_primary : i => v if !v.vm_pubip}
  name                                      = "${each.value.vm_name}-asr-replica"
  resource_group_name                       = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                       = azurerm_recovery_services_vault.asr_vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary.name
  source_vm_id                              = each.value.vm_id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary.name

  target_resource_group_id                = azurerm_resource_group.rg_secondary.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary.id

  managed_disk {
    disk_id                    = each.value.vm_osdisk_id
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = azurerm_resource_group.rg_secondary.id
    target_disk_type           = each.value.vm_osdisk_type
    target_replica_disk_type   = each.value.vm_osdisk_type
  }

  dynamic "managed_disk" {
    for_each                   = each.value.vm_datadisks !=null ? each.value.vm_datadisks : []
    content{
    disk_id                    = managed_disk.value["id"]
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = azurerm_resource_group.rg_secondary.id
    target_disk_type           = managed_disk.value["type"]
    target_replica_disk_type   = managed_disk.value["type"]
    }
  }

  network_interface {
      source_network_interface_id   = each.value.vm_existing_nic_id
      target_subnet_name            = azurerm_subnet.secondary.name
    }
  
  tags = var.tags

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.container-mapping,
    azurerm_site_recovery_network_mapping.network-mapping,
  ]
}