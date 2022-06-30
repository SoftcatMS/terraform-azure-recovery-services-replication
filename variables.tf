variable "location_primary" {
  type = string
  default = null
  description = "Azure location of where the exisiting VM resides"
}

variable "location_secondary" {
  type = string
  default = null
  description = "Azure location of where the VMs will need to be replicated to"
}

variable "asr_cache_resource_group_name" {
  type = string
  default = null
  description = "Azure resource group name of where the storgae account for replication cache should be created"
}

variable "resource_group_name_secondary" {
  type = string
  default = null
  description = "Azure resource group for secondary location of replicated resources"
}

variable "asr_vault_name" {
  type = string
  default = null
  description = "Azure ASR Vault Name"
}

variable "existing_vm_primary" {
  type = list(object({
    vm_name                           = string
    vm_resource_group_name            = string
    vm_osdisk_name                    = string
    vm_osdisk_resource_group_name     = string
    # vm_datadisk_name                  = list(string)
    # vm_datadisk_resource_group_name   = list(string)
    }))
  default = []
  description = "Azure existing VM information"
}

variable "existing_vm_networkinteface_name" {
  type = string
  default = null
  description = "Azure network interface name of interface attached to existing VM"
}

variable "existing_vm_networkinteface_resourcegroup_name" {
  type = string
  default = null
  description = "Azure resource group name of where existing network interface resides"
}

variable "existing_vnet_name_primary" {
  type = string
  default = null
  description = "Azure vNet name of exisitng network where primary VM resides"
}

variable "existing_vnet_resourcegroup_name" {
  type = string
  default = null
  description = "Azure resource group name of where exisitng vNet resides"
}

variable "existing_subnet_name_primary" {
  type = string
  default = null
  description = "Azure subnet name of exisitng subnet where primary VM resides"
}

variable "existing_subnet_resourcegroup_name" {
  type = string
  default = null
  description = "Azure resource group name of where exisitng subnet resides"
}

variable "recovery_point_retention_minutes" {
  type = string
  default = "24 * 60"
  description = "ASR policy setting. Sets the recovery point retention in minutes"
}

variable "app_consistent_snapshot_frequency_minutes" {
  type = string
  default = "4 * 60"
  description = "ASR policy setting. Sets the application consistent snapshot frequency in minutes"
}

variable "asr_vnet_address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network setup in the ASR replicated secondary location"
  default     = ["10.0.0.0/16"]
}

variable "asr_subnet_prefixes" {
  description = "The address prefix to use for the subnets in the ASR replicated secondary location"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}