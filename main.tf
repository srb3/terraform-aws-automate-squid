provider "aws" {
  shared_credentials_file = var.aws_creds_file
  profile                 = var.aws_profile
  region                  = var.aws_region
}

data "aws_availability_zones" "available" {}

module "ami" {
  source  = "srb3/ami/aws"
  version = "0.13.0"
  os_name = var.os_name
}

resource "random_id" "hash" {
  byte_length = 4
}

locals {
  public_subnets               = ["10.0.1.0/24"]
  azs                          = [
                                   data.aws_availability_zones.available.names[0],
                                   data.aws_availability_zones.available.names[1]
                                 ]
  sg_data = {
    "automate" = {
      "ingress_rules" = var.automate_ingress_rules,
      "ingress_cidr"  = var.automate_ingress_cidrs,
      "egress_rules"  = var.automate_egress_rules,
      "egress_cidr"   = concat(var.automate_egress_cidrs,local.public_subnets),
      "description"   = "automate security group"
      "vpc_id"        = module.vpc.vpc_id
    },
    "squid" = {
      "ingress_rules" = var.squid_ingress_rules,
      "ingress_cidr"  = concat(var.squid_ingress_cidrs,local.public_subnets),
      "egress_rules"  = var.squid_egress_rules,
      "egress_cidr"   = var.squid_egress_cidrs,
      "description"   = "squid security group"
      "vpc_id"        = module.vpc.vpc_id
    }
  }
  vm_data = {
    "automate" = {
      "ami"                = module.ami.id,
      "instance_type"      = var.automate_instance_type,
      "key_name"           = var.key_name,
      "security_group_ids" = [module.security_group["automate"].id],
      "subnet_ids"         = module.vpc.public_subnets,
      "root_block_device"  = var.rbd,
      "public_ip_address"  = true
    },
    "squid" = {
      "ami"                = module.ami.id,
      "instance_type"      = var.squid_instance_type,
      "key_name"           = var.key_name,
      "security_group_ids" = [module.security_group["squid"].id],
      "subnet_ids"         = module.vpc.public_subnets,
      "root_block_device"  = var.rbd,
      "public_ip_address"  = true
    }
  }
  proxy_string = "http://${module.instance["squid"].private_ip[0]}:3128"
  no_proxy_string = "0.0.0.0,127.0.0.1"
}

module "vpc" {
  source         = "srb3/vpc/aws"
  version        = "0.13.0"
  name           = "Automate and Squid vpc"
  cidr           = "10.0.0.0/16"
  azs            = local.azs
  public_subnets = local.public_subnets
  tags           = var.tags
}

module "security_group" {
  source              = "srb3/security-group/aws"
  version             = "0.13.1"
  for_each            = local.sg_data
  name                = each.key
  description         = each.value["description"]
  vpc_id              = each.value["vpc_id"]
  ingress_rules       = each.value["ingress_rules"]
  ingress_cidr_blocks = each.value["ingress_cidr"]
  egress_rules        = each.value["egress_rules"]
  egress_cidr_blocks  = each.value["egress_cidr"]
  tags                = var.tags
}

module "instance" {
  source                      = "srb3/vm/aws"
  version                     = "0.13.1"
  for_each                    = local.vm_data
  name                        = each.key
  ami                         = each.value["ami"]
  instance_type               = each.value["instance_type"]
  key_name                    = each.value["key_name"]
  security_group_ids          = each.value["security_group_ids"]
  subnet_ids                  = each.value["subnet_ids"]
  root_block_device           = each.value["root_block_device"]
  associate_public_ip_address = each.value["public_ip_address"] 
  tags                        = var.tags
}

module "automate_install" {
  source                   = "srb3/chef-automate/linux"
  version                  = "0.13.1"
  ip                       = module.instance["automate"].public_ip[0]
  ssh_user_name            = module.ami.user
  ssh_user_private_key     = var.automate_ssh_user_private_key
  products                 = var.automate_products
  config                   = var.automate_config
  admin_password           = var.automate_admin_password
  ingest_token             = var.automate_ingest_token
  hostname_method          = var.automate_hostname_method
  chef_automate_license    = var.automate_license
  fqdn                     = module.instance["automate"].public_ip[0]
  proxy_string             = local.proxy_string
  no_proxy_string          = local.no_proxy_string
  patching_override_origin = var.automate_patching_override_origin
  patching_hartifacts_path = var.automate_patching_hartifacts_path
  depends_on               = [module.squid_install]
}

module "automate_populate" {
  source           = "srb3/chef-automate-populate/linux"
  version          = "0.13.1"
  ip               = module.instance["automate"].public_ip[0]
  user_name        = module.ami.user
  user_private_key = var.automate_ssh_user_private_key
  enabled_profiles = var.automate_enabled_profiles
  automate_module  = jsonencode(module.automate_install)
  proxy_string     = local.proxy_string
  no_proxy_string  = local.no_proxy_string
}

module "squid_install" {
  source               = "srb3/squid/linux"
  version              = "0.13.1"
  ip                   = module.instance["squid"].public_ip[0]
  ssh_user_name        = module.ami.user
  ssh_user_private_key = var.squid_ssh_user_private_key
  ssl_ports            = var.squid_ssl_ports
  safe_ports           = var.squid_safe_ports
  localnets            = local.public_subnets
}

locals {
   tmp_path              = "/var/tmp"

   inspec_working_path   = "profiles"
   inspec_tmp_path       = "${local.tmp_path}/${local.inspec_working_path}"
   inspec_file_tmp_path  = "${local.inspec_tmp_path}/files"

   patching_working_path  = "patching"
   patching_tmp_path      = "${local.tmp_path}/${local.patching_working_path}"
   patching_file_tmp_path = "${local.patching_tmp_path}/files"

   profile_upload_command = templatefile("${path.module}/templates/profiles",{
    tmp_path      = local.inspec_tmp_path
    file_tmp_path = local.inspec_file_tmp_path
    file_pattern  = "*.tar.gz"
    ip            = module.instance["automate"].private_ip[0]
    token         = module.automate_populate.admin_token
  })

   patching_command = templatefile("${path.module}/templates/patches",{
    tmp_path         = local.patching_tmp_path
    file_tmp_path    = local.patching_file_tmp_path
    file_pattern     = "*.hart"
    destination_path = var.automate_patching_hartifacts_path
  })

}

module "inspec_profile_upload" {
  source               = "srb3/bulk-file-copy/util"
  version              = "0.13.1"
  ip                   = module.instance["automate"].public_ip[0]
  user_name            = module.ami.user
  ssh_user_private_key = var.automate_ssh_user_private_key
  local_path           = var.test_profile_local_dir
  file_pattern         = "*.tar.gz"
  script               = local.profile_upload_command
  working_path         = local.inspec_working_path
  tmp_path             = local.tmp_path
  depends_on           = [module.automate_populate]
}

module "hab_keys_upload" {
  source                 = "srb3/bulk-file-copy/util"
  version                = "0.13.1"
  ip                     = module.instance["automate"].public_ip[0]
  user_name              = module.ami.user
  ssh_user_private_key   = var.automate_ssh_user_private_key
  local_path             = var.automate_hartifact_keys_local_path
  remote_privileged_path = var.automate_hartifact_keys_remote_path
  file_pattern           = "${var.automate_patching_override_origin}*"
  working_path           = "hab_keys_upload"
  depends_on             = [module.inspec_profile_upload]
}

module "hab_pkg_upload" {
  source                 = "srb3/bulk-file-copy/util"
  version                = "0.13.1"
  ip                     = module.instance["automate"].public_ip[0]
  user_name              = module.ami.user
  ssh_user_private_key   = var.automate_ssh_user_private_key
  local_path             = var.automate_patching_hartifacts_local_path
  file_pattern           = "*.hart"
  script                 = local.patching_command
  working_path           = local.patching_working_path
  tmp_path               = local.tmp_path
  depends_on             = [module.hab_keys_upload]
}


