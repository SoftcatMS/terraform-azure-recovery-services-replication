# Contributing

This document provides guidelines for contributing to the module.

## Dependencies

The following dependencies must be installed on the development system:

- [Terraform](https://www.terraform.io/downloads.html) 

Azure  
- [Terraform Provider for Azure](https://github.com/hashicorp/terraform-provider-azurerm)
- CLI Tool [az](https://docs.microsoft.com/en-us/cli/azure/)

AWS  
- [Terraform Provider for AWS](https://github.com/hashicorp/terraform-provider-aws)
- CLI Tool [aws-cli](https://aws.amazon.com/cli/)

GCP  
- [Terraform Provider for GCP](https://github.com/hashicorp/terraform-provider-google)
- [Terraform Provider for GCP Beta](https://github.com/terraform-providers/terraform-provider-google-beta)
- CLI Tool [gcloud](https://cloud.google.com/sdk/gcloud/)

## Generating Documentation for Inputs and Outputs

The Inputs and Outputs tables in the READMEs of the root module,
submodules, and example modules are automatically generated based on
the `variables` and `outputs` of the respective modules. These tables
must be refreshed if the module interfaces are changed.

This can be achieved by using [terraform-docs](https://github.com/terraform-docs/terraform-docs)

`terraform-docs markdown ./terraform-module-name`

## Integration Testing

Integration tests are used to verify the behaviour of the root module,
submodules, and example modules. Additions, changes, and fixes should
be accompanied with tests.

Test are located in folder [tests](./tests)

When updating a test you will need to reflect that update and test for its result where possible using Inspec. 
These tests can be found in:

[basic_tests](./tests/basic/azure-inspec-tests/controls)  
[advanced_tests](./tests/advanced/azure-inspec-tests/controls)  

Documentation can be found here:

[Inspec_Azure](https://github.com/inspec/inspec-azure)

## Linting and Formatting

Many of the files in the repository can be linted or formatted to
maintain a standard of quality using `terraform fmt`
