module "asr" {
    source                          = "../../"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = "VM-Test"
    resource_group_name_secondary   = "rg-asr-secondary"
    asr_vault_name                  = "asr-vault-replication"
    
    existing_vm_primary = [
        {
        vm_name                         = "WinVM-Test1"
        vm_id                           = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/virtualMachines/WinVM-Test1"
        vm_osdisk_id                    = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-TEST/providers/Microsoft.Compute/disks/WinVM-Test1_OsDisk_1_6dd04c68692d4ddf9abeaa541cf08f7b"
        vm_osdisk_type                  = "Premium_LRS"
        # vm_datadisk_names               = [""]
        # vm_datadisk_ids                 = [""]
        # vm_datadis_types                = [""]
        }
    ]  

    existing_vm_networkinteface_id      = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Network/networkInterfaces/winvm-test1590"
    existing_vnet_id_primary            = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Network/virtualNetworks/VM-Test-vnet"

}