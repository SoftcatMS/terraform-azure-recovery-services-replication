resource "azurerm_resource_group" "rg-vm-test-basic" {
  name     = "rg-test-asr-basic-resources"
  location = "UK South"
}

module "vnet" {

  source              = "github.com/SoftcatMS/azure-terraform-vnet"
  vnet_name           = "vnet-asr-test-basic"
  resource_group_name = azurerm_resource_group.rg-vm-test-basic.name
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.1.0/24"]
  subnet_names        = ["subnet1"]

  subnet_service_endpoints = {
    "subnet1" : ["Microsoft.Storage"]
  }

  tags = {
    environment = "test"
    engineer    = "ci/cd"
  }

  depends_on = [azurerm_resource_group.rg-vm-test-basic]
}

module "asr" {
    source                          = "github.com/SoftcatMS/terraform-azure-site-recovery"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = azurerm_resource_group.rg-vm-test-basic.name
    resource_group_name_secondary   = "ukw-asr-test-basic"
    asr_vault_name                  = "ukw-asr-vault-test-basic"
    asr_fabric_primary_name         = "primary-fabric-basic"
    asr_fabric_secondary_name       = "secondary-fabric-basic"
    existing_vnet_id_primary        = module.vnet.vnet_id
    existing_subnet_id              = module.vnet.vnet_subnets[0]
    
    tags = {
      environment = "test"
      engineer    = "ci/cd"
  }

    depends_on = [azurerm_resource_group.rg-vm-test-basic]
}