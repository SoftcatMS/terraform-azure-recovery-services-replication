resource "random_string" "random_string" {
  length = 5
  special = false
  lower = true
  upper = false
  numeric = true
}

data "azurerm_virtual_machine" "primary" {
    for_each              = var.existing_vm_primary
    name                  = each.value.vm_name
    resource_group_name   = each.value.vm_resource_group_name
}

data "azurerm_virtual_network" "primary" {
    name                  = var.existing_vnet_name_primary
    resource_group_name   = var.existing_vnet_resourcegroup_name
}

data "azurerm_subnet" "primary" {
    name                  = var.existing_subnet_name_primary
    resource_group_name   = var.existing_subnet_resourcegroup_name
    virtual_network_name  = var.existing_vnet_name_primary
}

data "azurerm_network_interface" "primary" {
    name                  = var.existing_vm_networkinteface_name
    resource_group_name   = var.existing_vm_networkinteface_resourcegroup_name
}

data "azurerm_managed_disk" "primary_os" {
    for_each              = var.existing_vm_primary
    name                  = each.value.vm_osdisk_name
    resource_group_name   = each.value.vm_osdisk_resource_group_name
}

# data "azurerm_managed_disk" "primary_datadisks" {
#     for_each              = var.existing_vm_primary
#     name                  = each.value.vm_datadisk_name
#     resource_group_name   = each.value.vm_datadisk_resource_group_name
# }

resource "azurerm_resource_group" "rg_secondary" {
  name = var.resource_group_name_secondary
  location = var.location_secondary
}

resource "azurerm_recovery_services_vault" "asr_vault" {
  name                = "${var.asr_vault_name}"
  location            = var.location_secondary
  resource_group_name = azurerm_resource_group.rg_secondary.name
  sku                 = "Standard"
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
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                       = azurerm_recovery_services_vault.asr_vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
}

resource "azurerm_site_recovery_network_mapping" "network-mapping" {
  name                        = "network-mapping"
  resource_group_name         = azurerm_resource_group.rg_secondary.name
  recovery_vault_name         = azurerm_recovery_services_vault.asr_vault.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
  source_network_id           = data.azurerm_virtual_network.primary.id
  target_network_id           = azurerm_virtual_network.secondary.id
}

resource "azurerm_storage_account" "primary" {
  name                     = "asrrecoverycache${random_string.random_string.result}"
  location                 = var.location_primary
  resource_group_name      = var.asr_cache_resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "secondary" {
  name                = "asr-network"
  resource_group_name = azurerm_resource_group.rg_secondary.name
  address_space       = var.asr_vnet_address_space
  location            = azurerm_resource_group.rg_secondary.location
}

resource "azurerm_subnet" "secondary" {
  name                 = "asr-subnet"
  resource_group_name  = azurerm_resource_group.rg_secondary.name
  virtual_network_name = azurerm_virtual_network.secondary.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_public_ip" "secondary" {
  name                = "vm-public-ip-secondary-test2"
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg_secondary.location
  resource_group_name = azurerm_resource_group.rg_secondary.name
  sku                 = "Basic"
}

resource "azurerm_site_recovery_replicated_vm" "vm-replication" {
  for_each                                  = data.azurerm_virtual_machine.primary
  name                                      = "${data.azurerm_virtual_machine.primary[each.key].name}-asr-replica"
  resource_group_name                       = azurerm_resource_group.rg_secondary.name
  recovery_vault_name                       = azurerm_recovery_services_vault.asr_vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary.name
  source_vm_id                              = data.azurerm_virtual_machine.primary[each.key].id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary.name

  target_resource_group_id                = azurerm_resource_group.rg_secondary.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary.id

  managed_disk {
    disk_id                    = data.azurerm_managed_disk.primary_os[each.key].id
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = azurerm_resource_group.rg_secondary.id
    target_disk_type           = data.azurerm_managed_disk.primary_os[each.key].storage_account_type
    target_replica_disk_type   = data.azurerm_managed_disk.primary_os[each.key].storage_account_type
  }

  # managed_disk {
  #   for_each                   = data.azurerm_managed_disk.primary_datadisks
  #   disk_id                    = data.azurerm_managed_disk.primary_datadisks[each.key].id
  #   staging_storage_account_id = azurerm_storage_account.primary.id
  #   target_resource_group_id   = azurerm_resource_group.rg_secondary.id
  #   target_disk_type           = data.azurerm_managed_disk.primary_datadisks[each.key].storage_account_type
  #   target_replica_disk_type   = data.azurerm_managed_disk.primary_datadisks[each.key].storage_account_type
  # }

  network_interface {
    source_network_interface_id   = data.azurerm_network_interface.primary.id
    target_subnet_name            = azurerm_subnet.secondary.name
    recovery_public_ip_address_id = azurerm_public_ip.secondary.id
  }

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.container-mapping,
    azurerm_site_recovery_network_mapping.network-mapping,
  ]
}