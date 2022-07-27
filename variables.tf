variable "location_primary" {
  type = string
  default = null
  description = "Azure location of where the exisiting VMs reside"
}

variable "location_secondary" {
  type = string
  default = null
  description = "Azure location of where the VMs will need to be replicated to"
}

variable "asr_cache_resource_group_name" {
  type = string
  default = null
  description = "Azure resource group name of where the storage account for replication cache should be created"
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
  description = "Azure exisiting VMs information. The object 'vm_pubip' should be set to true if a public IP is required for the VM and the 'vm_datadisks' allows for multiple data disks to be specified"  
  type = list(object({
    vm_name             = string
    vm_id               = string
    vm_osdisk_id        = string
    vm_osdisk_type      = string
    vm_existing_nic_id  = string
    vm_pubip            = bool
    vm_datadisks        = list(object({
      id                = string
      type              = string
    }))
  }))
  default = []
}
  

variable "existing_vm_networkinteface_id" {
  type = string
  default = null
  description = "Azure network interface id of interface attached to existing VM"
}

variable "existing_vnet_id_primary" {
  type = string
  default = null
  description = "Azure vNet id of exisitng network where primary VM resides"
}

variable "existing_subnet_id" {
  type = string
  default = null
  description = "Azure subnet id of the existing subnet where one the primary VM resides. Please ensure this subnet has the Microsoft.Storage service endpoint enabled"
}

variable "recovery_point_retention_minutes" {
  type = number
  default = 24 * 60
  description = "ASR policy setting. Sets the recovery point retention in minutes"
}

variable "app_consistent_snapshot_frequency_minutes" {
  type = number
  default = 4 * 60
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

variable "tags" {
  description = "A map of the tags to use on the resources that are deployed with this module."
  type        = map(string)
  default     = []
}