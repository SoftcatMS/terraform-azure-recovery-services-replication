# terraform-azure-site-recovery
Deploys Azure Site Recovery vault and configures replication for existing Azure VMs.

`Prerequisite` the subnets where the exisitng VMs reside must have the 'Microsoft.Storage' service endpoint enabled to allow access to the replication cache storage account

`WARNING` adding additional disks to a VM already replicated will destory the current replication first before the entire VM is re-replicated. This can take additional time to complete.

## Usage Examples
Review the examples folder: [examples](./examples)

## Deployment
Perform the following commands on the root folder:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure


use terraform-docs to create Inputs and Outpus documentation  [terraform-docs](https://github.com/terraform-docs/terraform-docs)

`terraform-docs markdown .`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =2.97.0 |      

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | =2.97.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip.secondary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/public_ip) | resource |
| [azurerm_recovery_services_vault.asr_vault](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/recovery_services_vault) | resource |
| [azurerm_resource_group.rg_secondary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.asr_contributor_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.asr_storageblobdatacontributor_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/role_assignment) | resource |
| [azurerm_site_recovery_fabric.primary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_fabric) | resource |
| [azurerm_site_recovery_fabric.secondary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_fabric) | resource |
| [azurerm_site_recovery_network_mapping.network-mapping](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_network_mapping) | resource |
| [azurerm_site_recovery_protection_container.primary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_protection_container) | resource |
| [azurerm_site_recovery_protection_container.secondary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_protection_container) | resource |
| [azurerm_site_recovery_protection_container_mapping.container-mapping](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_protection_container_mapping) | resource |     
| [azurerm_site_recovery_replicated_vm.vm-replication-no-pubip](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_replicated_vm) | resource |
| [azurerm_site_recovery_replicated_vm.vm-replication-pubip](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_replicated_vm) | resource |
| [azurerm_site_recovery_replication_policy.policy](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/site_recovery_replication_policy) | resource |
| [azurerm_storage_account.primary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/storage_account) | resource |
| [azurerm_subnet.secondary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/subnet) | resource |
| [azurerm_virtual_network.secondary](https://registry.terraform.io/providers/hashicorp/azurerm/2.97.0/docs/resources/virtual_network) | resource |
| [random_string.random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_consistent_snapshot_frequency_minutes"></a> [app\_consistent\_snapshot\_frequency\_minutes](#input\_app\_consistent\_snapshot\_frequency\_minutes) | ASR policy setting. Sets the application consistent snapshot frequency in minutes | `number` | `240` | no |
| <a name="input_asr_cache_resource_group_name"></a> [asr\_cache\_resource\_group\_name](#input\_asr\_cache\_resource\_group\_name) | Azure resource group name of where the storgae account for replication cache should be created | `string` | `null` | no |
| <a name="input_asr_subnet_prefixes"></a> [asr\_subnet\_prefixes](#input\_asr\_subnet\_prefixes) | The address prefix to use for the subnets in the ASR replicated secondary location | `list(string)` | <pre>[<br>  
"10.0.1.0/24"<br>]</pre> | no |
| <a name="input_asr_vault_name"></a> [asr\_vault\_name](#input\_asr\_vault\_name) | Azure ASR Vault Name | `string` | `null` | no |
| <a name="input_asr_vnet_address_space"></a> [asr\_vnet\_address\_space](#input\_asr\_vnet\_address\_space) | The address space that is used by the virtual network setup in the ASR replicated secondary location | 
`list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_existing_subnet_id"></a> [existing\_subnet\_id](#input\_existing\_subnet\_id) | Azure subnet id of the existing subnet where one the primary VM resides. Please ensure this subnet has the Microsoft.Storage service endpoint enabled | `string` | `null` | no |
| <a name="input_existing_vm_networkinteface_id"></a> [existing\_vm\_networkinteface\_id](#input\_existing\_vm\_networkinteface\_id) | Azure network interface id of interface attached to existing VM | `string` | `null` | no |
| <a name="input_existing_vm_primary"></a> [existing\_vm\_primary](#input\_existing\_vm\_primary) | Azure exisiting VMs information. The object 'vm\_pubip' should be set to true if a public IP is required for the VM and the 'vm\_datadisks' allows for multiple data disks to be specified | <pre>list(object({<br>    vm_name             = string<br>    vm_id               = string<br>    vm_osdisk_id        = string<br>    vm_osdisk_type      = string<br>    vm_existing_nic_id  = string<br>    vm_pubip            = bool<br>    vm_datadisks        = list(object({<br>      id                = string<br>      type              = string<br>  
  }))<br>  }))</pre> | `[]` | no |
| <a name="input_existing_vnet_id_primary"></a> [existing\_vnet\_id\_primary](#input\_existing\_vnet\_id\_primary) | Azure vNet id of exisitng network where primary VM resides | `string` | `null` | no |
| <a name="input_location_primary"></a> [location\_primary](#input\_location\_primary) | Azure location of where the exisiting VMs reside | `string` | `null` | no |
| <a name="input_location_secondary"></a> [location\_secondary](#input\_location\_secondary) | Azure location of where the VMs will need to be replicated to | `string` | `null` | no |
| <a name="input_recovery_point_retention_minutes"></a> [recovery\_point\_retention\_minutes](#input\_recovery\_point\_retention\_minutes) | ASR policy setting. Sets the recovery point retention in minutes | `number` | `1440` | no |
| <a name="input_resource_group_name_secondary"></a> [resource\_group\_name\_secondary](#input\_resource\_group\_name\_secondary) | Azure resource group for secondary location of replicated resources | `string` | `null` | no |

## Outputs

No outputs.
