# copyright: 2018, The Authors

# Test values

resource_group1 = 'rg-test-asr-advanced-resources'

describe azurerm_recovery_services_vault(resource_group: resource_group1, name: 'ukw-asr-vault-test-advanced') do
  it { should exist }
end

describe azure_virtual_machine(resource_group: resource_group1, name: 'wintest-vm-adv') do
  it { should exist }
  its('os_disk_name') { should match 'wintest-vm-adv-osdisk' }

end