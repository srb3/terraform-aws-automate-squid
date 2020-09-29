########### AWS settings #########################

variable "aws_creds_file" {
  description = "The path to an aws credentials file"
  type        = string
}

variable "aws_profile" {
  description = "The name of an aws profile to use"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "The aws region to use"
  type        = string
  default     = "eu-west-1"
}

variable "tags" {
  description = "A set of tags to assign to the instances created by this module"
  type        = map(string)
  default     = {}
}

########### base vm settings #####################

variable "os_name" {
  description = "The name of the operating system to use"
  type        = string
  default     = "centos-7"
}

variable "key_name" {
  description = "The name of an aws key pair to use for chef automate"
  type        = string
}

variable "rbd" {
  description = "A list of maps describing the root block device or devices"
  type        = list(map(string))
  default     = [{ volume_type = "gp2", volume_size = "40" }]
}

########### automate security settings ###########

variable "automate_ingress_rules" {
  description = "Rules for traffic comming into chef automate"
  type        = list(string)
  default     = ["ssh-tcp", "http-80-tcp", "https-443-tcp"]
}

variable "automate_egress_rules" {
  description = "Rules for traffic leaving chef automate"
  type        = list(string)
  default     = ["all-all"]
}

variable "automate_ingress_cidrs" {
  description = "A list of CIDR's to use for allowing access to the automate vm"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "automate_egress_cidrs" {
  description = "A list of CIDR's to use for allowing access out from chef autoamte"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

########### squid security settings ##############

variable "squid_ingress_rules" {
  description = "Rules for traffic comming into the squid proxy"
  type        = list(string)
  default     = ["ssh-tcp", "squid-proxy-tcp"]
}

variable "squid_egress_rules" {
  description = "Rules for traffic leaving the squid proxy"
  type        = list(string)
  default     = ["all-all"]
}

variable "squid_ingress_cidrs" {
  description = "A list of CIDR's to use for allowing access to the squid vm"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "squid_egress_cidrs" {
  description = "A list of CIDR's to use for allowing access out from the squid proxy"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

########### automate vm settings #################

variable "automate_instance_type" {
  description = "The name of the instance type to use for chef automate"
  type        = string
  default     = "t3.large"
}

########### squid vm settings ####################


variable "squid_instance_type" {
  description = "The name of the instance type to use for chef squid"
  type        = string
  default     = "t3.large"
}

############ automate install settings ###########

variable "automate_ssh_user_private_key" {
  description = "The ssh private key used to access the automate vm"
  type        = string
}

variable "automate_products" {
  description = "A list of automate products to install"
  type        = list(string)
  default     = ["automate"]
}

variable "automate_config" {
  description = "A string of config options to pass to chef automate"
  type        = string
  default     = ""
}

variable "automate_ingest_token" {
  description = "The string to use as the automate admin token"
  type        = string
  default     = "automateingesttoken1234"
}

variable "automate_admin_password" {
  description = "The admin password to set for chef automate"
  type        = string
  default     = "automateadminpassword"
}

variable "automate_license" {
  description = "The license to set for chef automate"
  type        = string
  default     = ""
}

variable "automate_hostname_method" {
  description = "The method to use for setting the hostname."
  type        = string
  default     = "external_fqdn"
}


variable "automate_patching_override_origin" {
  description = "Override this value if you want to patch chef automate with your own habitat builds"
  type        = string
  default     = "chef"
}

variable "automate_patching_hartifacts_path" {
  description = "Configure chef automate to use this location to look for patches"
  type        = string
  default     = "/hab/results"
}

############ squid install settings ###########

variable "squid_ssh_user_private_key" {
  description = "The ssh private key used to access the squid proxy"
  type        = string
}

variable "squid_ssl_ports" {
  description = "A list of ports to use as ssl_ports in the squid config"
  type        = list(string)
  default     = ["443"]
}

variable "squid_safe_ports" {
  description = "A list of ports to use as safe_ports in the squid config"
  type        = list(string)
  default     = ["443","80"]
}

########### automate populate settings ##########

variable "automate_enabled_profiles" {
  description = "A list of profiles to enable from the automate profile market place"
  type        = list(map(string))
  default     = []
}

########### automate file upload settings #######

variable "aws_test_profile_name" {
  description = "The name of the aws test profile"
  type        = string
  default     = "aws-test-1.0.0.tar.gz"
}

variable "test_profile_local_dir" {
  description = "The directory that hold the aws test profile"
  type        = string
  default     = "inspec_profiles"
}

variable "test_profile_remote_dir" {
  description = "The path (on the chef automate server) to copy the aws profile to"
  type        = string
  default     = "/var/tmp/inspec_profiles"
}

variable "login_cmd" {
  description = "The inspec compliance login command base"
  type        = string
  default     = "sudo hab pkg exec chef/inspec inspec compliance login"
}

variable "upload_cmd" {
  description = "The inspec compliance upload command base"
  type        = string
  default     = "sudo hab pkg exec chef/inspec inspec compliance upload"
}

variable "automate_patching_hartifacts_local_path" {
  description = "The path to a directory containing any chef automate patches you want to apply to chef automate"
  type        = string
  default     = "automate_patches/"
}

########### automate hartifact keys ##############

variable "automate_hartifact_keys_local_path" {
  description = "The path to a directory containg any hartifact keys"
  type        = string
  default     = "habitat_key_files/"
}

variable "remote_tmp_path" {
  description = "The temporary path to use for hartifact key transfer"
  type        = string
  default     = "/var/tmp/"
}

variable "automate_hartifact_keys_tmp_remote_path" {
  description = "The path to a staging directory to hold the hab keys"
  type        = string
  default     = "hab_keys"
}

variable "automate_hartifact_keys_remote_path" {
  description = "The path to a directory on the chef automate server to upload keys to"
  type        = string
  default     = "/hab/cache/keys"
}
