# Overview

Requires terraform v0.13.x

* copy terraform.tfvars.example to terraform.tfvars
* fill out the missing variables with your info
* create two folders automate_patches and habitat_key_files
* place your automate component test builds (hart files) in the automate_patches folder
* place your required habitat keys for your origin (I think it's just the signing key needed) into the habitat_key_files folder
* run `terraform init`, `terraform plan` and then `terraform apply`

## workflow of terraform
The terraform code will create the resources and execute the tasks listed below (listed in order)
* VPC
* Subnets
* Security Groups
* Squid VM
* Automate VM
* Squid installation
* Chef Automate installation 
* Any profiles in the `inspec_profiles` folder are copied to the Chef Automate VM and installed
* Any key files in the `habitat_key_files` folder are copied to the Chef Automate and placed in the `/hab/cache/keys/` folder
* Any hart files in the `automate_patches` folder are copied to the `/hab/results` folder on the Chef Automate VM, then the deployment service is killed triggering a restart of any services that have a new package in the `results` folder

