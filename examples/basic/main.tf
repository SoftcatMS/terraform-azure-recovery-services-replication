resource "azurerm_resource_group" "rg-vm-example-basic" {
  name     = "rg-example-asr-basic-resources"
  location = "UK South"
}

module "vnet" {

  source              = "github.com/SoftcatMS/azure-terraform-vnet"
  vnet_name           = "vnet-asr-example-basic"
  resource_group_name = azurerm_resource_group.rg-vm-example-basic.name
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.1.0/24"]
  subnet_names        = ["subnet1"]

  subnet_service_endpoints = {
    "subnet1" : ["Microsoft.Storage"]
  }

  tags = {
    environment = "example"
    engineer    = "ci/cd"
  }

  depends_on = [azurerm_resource_group.rg-vm-example-basic]
}

module "asr" {
    source                          = "github.com/SoftcatMS/terraform-azure-site-recovery?ref=data-disk-multiple-vms"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = azurerm_resource_group.rg-vm-example-basic.name
    resource_group_name_secondary   = "ukw-asr-example-basic"
    asr_vault_name                  = "ukw-asr-vault-example-basic"
    existing_vnet_id_primary        = module.vnet.vnet_id
    existing_subnet_id              = module.vnet.vnet_subnets[0]
    
    tags = {
      environment = "example"
      engineer    = "ci/cd"
  }

    depends_on = [azurerm_resource_group.rg-vm-example-basic]
}