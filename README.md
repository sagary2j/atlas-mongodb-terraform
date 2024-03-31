# MongoDB atlas cluster creation with Terraform

## Pre-requisites
Terraform
- Basic understanding of Terraform concepts and Terraform CLI installed.
- AWS VPC with subnets and route tables.
- MongoDB Atlas account.
- MongoDB Atlas Organization and a Project under your account with public and private keys with Organization Project Creator API key.

### To Plan and Apply
```sh

$ terraform init
$ terraform plan -var-file="environment.tfvars"
$ terraform apply -var-file="environment.tfvars"
$ terraform destroy -var-file="environment.tfvars"
```
