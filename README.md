# Overview
Quickly create a chef automate instace for testing

#### Supported platform families:
  * Debian
  * RHEL
  * SUSE

#### Version Note
The latest version of this repo only supports Terraform version 13, to use with terrafrom version 12 please one of the tags before v0.13.0

## Usage
There are two ways to consume this module:

### 1. Direct
clone the repo from github, copy the terraform.tfvars.example file to terraform.tfvars and fill in the missing
variables

#### Example
```
aws_region                          = "eu-west-1"
aws_profile                         = "testing"
aws_creds_file                      = "/home/jdoe/.aws/credentials"

automate_cidrs                      = ["53.61.3.2/32"]
automate_key_name                   = "jdoe_key"
automate_ssh_user_private_key       = "/home/jdoe/.ssh/eu_west_1"
automate_ingest_token               = "token1234"
automate_admin_password             = "zaq12wsx"
automate_create                     = true

automate_instance_type              = "t3.large"
automate_products                   = ["automate"] # or ["automate", "infra-server"] for automate and chef server

# Note this should only be provided with a valid Automate license
automate_license = "dadjaslkdjsakldjaslkjdlaskjdlaskdjaskldjaskldjaskldj"

automate_enabled_profiles = [
  {
    "name"    = "cis-aws-benchmark-level1",
    "version" = "latest",
    "owner"   = "admin"
  },
  {
    "name"    = "cis-sles11-level1",
    "version" = "1.1.0-7",
    "owner"   = "admin"
  }
]

tags = {
  "X-Dept" = "Eng",
  "X-Contact" = "jdoe@chef.io",
  "X-Project" = "testing"
}
```
Then run:
```
terraform init
terraform plan
terraform apply
```


### 2. As a module

You can refer to this code as a module in your own terraform file.

#### Example
```
variable "aws_region" {}
variable "aws_profile" {}
variable "aws_creds_file" {}

variable "automate_create" {}
variable "automate_key_name" {}
variable "automate_instance_type" {}
variable "automate_cidrs" {}
variable "automate_ssh_user_private_key" {}
variable "automate_ingest_token" {}
variable "automate_admin_password" {}
variable "automate_products" {}
variable "automate_license" {}
variable "automate_enabled_profiles" {}

variable "tags" {}

module "some_other_terraform" {
...
...
...
}

module "automate" {
  source                        = "srb3/chef-automate/aws"
  version                       = "0.13.1"
  aws_region                    = var.aws_region
  aws_profile                   = var.aws_profile
  aws_creds_file                = var.aws_creds_file
  automate_create               = var.automate_create
  automate_key_name             = var.automate_key_name
  automate_instance_type        = var.automate_instance_type
  automate_cidrs                = var.automate_cidrs
  automate_ssh_user_private_key = var.automate_ssh_user_private_key
  automate_ingest_token         = var.automate_ingest_token
  automate_admin_password       = var.automate_admin_password
  automate_products             = var.automate_products
  automate_license              = var.automate_license
  automate_enabled_profiles     = var.automate_enabled_profiles
  tags                          = var.tags
}

```



the profiles specified in the `automate_enabled_profiles` list will be automatically enabled on the chef automate instance. And an ingest token will be created matching the string provided in the `automate_ingest_token` variable
