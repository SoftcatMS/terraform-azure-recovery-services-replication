# copyright: 2018, The Authors

# Test values

describe azure_resource_group(name: 'rg-ukw-asr-test-advanced') do
  it { should exist }
end

describe azure_virtual_machine(resource_group: resource_group2, name: 'wintest-vm-adv') do
  it { should exist }
  its('os_disk_name') { should match 'wintest-vm-adv-osdisk' }

end