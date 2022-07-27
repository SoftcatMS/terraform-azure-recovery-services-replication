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

