module "asr" {
    source                          = "../../"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = "VM-Test"
    resource_group_name_secondary   = "UKW-RG-ASR"
    asr_vault_name                  = "UKW-ASR-VAULT"
    existing_vnet_id_primary        = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Network/virtualNetworks/VM-Test-vnet"
    existing_vm_primary = [
        {
        vm_name                         = "WinVM-Test1"
        vm_id                           = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/virtualMachines/WinVM-Test1"
        vm_osdisk_id                    = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-TEST/providers/Microsoft.Compute/disks/WinVM-Test1_OsDisk_1_6dd04c68692d4ddf9abeaa541cf08f7b"
        vm_osdisk_type                  = "Premium_LRS"
        vm_existing_nic_id              = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Network/networkInterfaces/winvm-test1590"
        },
        {
        vm_name                         = "WinVM-Test2"
        vm_id                           = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/virtualMachines/WinVM-Test2"
        vm_osdisk_id                    = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-TEST/providers/Microsoft.Compute/disks/WinVM-Test2_disk1_64c880b958a14cbc8cedce7f043475f1"
        vm_osdisk_type                  = "Premium_LRS"
        vm_existing_nic_id              = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Network/networkInterfaces/winvm-test2148"
        vm_datadisks                    = [{
            id                          = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Compute/disks/winvm-test2_datadisk1"
            type                        = "Premium_LRS"
        }]
        }
    ]  
}