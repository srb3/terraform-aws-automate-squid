# Overview

Requires terraform v0.13.x

* copy terraform.tfvars.example to terraform.tfvars
* fill out the missing variables with your info
* create two folders automate_patches and habitat_key_files
* place your automate component test builds (hart files) in the automate_patches folder
* place your required habitat keys for your origin (I think its just the signing key needed) into the habitat_key_files folder
* run `terraform init`, `terraform plan` and then `terraform apply`

