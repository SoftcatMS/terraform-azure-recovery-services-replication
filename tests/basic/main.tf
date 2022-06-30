module "asr" {
    source                          = "../../"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = "VM-Test"
    resource_group_name_secondary   = "rg-asr-secondary"
    asr_vault_name                  = "asr-vault-replication"
    
    existing_vm_primary = [{
        vm_name                         = "WinVM-Test1"
        vm_resource_group_name          = "VM-Test"
        vm_osdisk_name                  = "WinVM-Test1_OsDisk_1_6dd04c68692d4ddf9abeaa541cf08f7b"
        vm_osdisk_resource_group_name   = "VM-Test"
    }]  

    existing_vm_networkinteface_name                = "winvm-test1590"
    existing_vm_networkinteface_resourcegroup_name  = "VM-Test"
    existing_vnet_name_primary                      = "VM-Test-vnet"
    existing_vnet_resourcegroup_name                = "VM-Test"
    existing_subnet_name_primary                    = "default"
    existing_subnet_resourcegroup_name              = "VM-Test"

}