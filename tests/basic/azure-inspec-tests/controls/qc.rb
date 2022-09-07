# copyright: 2018, The Authors

# Test values

resource_group1 = 'rg-ukw-asr-test-basic'

describe azure_generic_resource(resource_group: resource_group1, name: 'rg-ukw-asr-test-basic') do
  it { should exist }
end