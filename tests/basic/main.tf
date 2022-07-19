module "asr" {
    source                          = "../../"
    location_primary                = "uksouth"
    location_secondary              = "westeurope"
    asr_cache_resource_group_name   = "VM-Test"
    resource_group_name_secondary   = "UKW-RG-ASR"
    asr_vault_name                  = "UKW-ASR-VAULT"
    existing_vnet_id_primary        = "/subscriptions/b5daafd9-87e5-4d14-9e0a-7009ef189fb8/resourceGroups/VM-Test/providers/Microsoft.Network/virtualNetworks/VM-Test-vnet" 
}