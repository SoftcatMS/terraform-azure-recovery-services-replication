data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg-vm-test-advanced" {
  name     = "rg-test-asr-advanced-resources"
  location = "UK South"
}

module "vnet" {

  source              = "github.com/SoftcatMS/azure-terraform-vnet"
  vnet_name           = "vnet-asr-test-advanced"
  resource_group_name = azurerm_resource_group.rg-vm-test-advanced.name
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

  depends_on = [azurerm_resource_group.rg-vm-test-advanced]
}

module "vm" {

  source                        = "github.com/SoftcatMS/azure-terraform-vm/modules/windows-vm"
  name                          = "wintest-vm-adv"
  resource_group_name           = azurerm_resource_group.rg-vm-test-advanced.name
  location                      = azurerm_resource_group.rg-vm-test-advanced.location
  virtual_machine_size          = "Standard_B2s"
  admin_password                = "ComplxP@ssw0rd!" // Password should not be provided in plain text. Use secrets
  enable_public_ip              = true
  public_ip_dns                 = "wintestadvancedvmip" // change to a unique name per datacenter region
  vnet_subnet_id                = module.vnet.vnet_subnets[0]
  enable_accelerated_networking = false

  source_image_publisher = "MicrosoftWindowsServer"
  source_image_offer     = "WindowsServer"
  source_image_sku       = "2019-Datacenter"
  source_image_version   = "latest"


  os_disk = [{
    disk_size_gb         = 150
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }]


  data_disks = [
    {
      name                 = "disk1"
      lun                  = 1
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
      caching              = "ReadWrite"
    },
    {
      name                 = "disk2"
      lun                  = 2
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
    }
  ]


  nsg_inbound_rules = [
    {
      name                       = "rdp"
      destination_port_range     = "3389"
      source_address_prefix      = "*"
      destination_address_prefix = "10.1.1.0/24"
    },
    {
      name                       = "http"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "10.1.1.0/24"
    },
  ]

  depends_on = [azurerm_resource_group.rg-vm-test-advanced]
}

module "asr" {
    source                          = "github.com/SoftcatMS/terraform-azure-site-recovery?ref=MAB-322-Adjust-data-disk-types-to-use-module-outputs"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = azurerm_resource_group.rg-vm-test-advanced.name
    resource_group_name_secondary   = "ukw-asr-test-advanced"
    asr_vault_name                  = "ukw-asr-vault-test-advanced"
    asr_fabric_primary_name         = "primary-fabric-advanced"
    asr_fabric_secondary_name       = "secondary-fabric-advanced"
    existing_vnet_id_primary        = module.vnet.vnet_id
    existing_subnet_id              = module.vnet.vnet_subnets[0]
    existing_vm_primary = [
        {
        vm_name                         = "wintest-vm-adv"
        vm_id                           = module.vm.virtual_machine_id
        vm_osdisk_id                    = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg-vm-test-advanced.name}/providers/Microsoft.Compute/disks/${module.vm.os_disk_name}"
        vm_osdisk_type                  = module.vm.os_disk_type
        vm_existing_nic_id              = module.vm.network_interface_id
        vm_pubip                        = false
        vm_datadisks                    = [
          {
            id                          = module.vm.data_disk_ids[0]
            type                        = module.vm.data_disk_types[0]
          },
          {
            id                          = module.vm.data_disk_ids[1]
            type                        = module.vm.data_disk_types[1]
          }
        ]
        }
    ]
    
    depends_on = [module.vm]  
}