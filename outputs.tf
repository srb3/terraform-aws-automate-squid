locals {

  ui = [
    for i in module.instance["automate"].public_ip :
      "https://${i}"
  ]

  automate_connection_string = [
    for i in module.instance["automate"].public_ip :
      "ssh -i ${var.automate_ssh_user_private_key} ${module.ami.user}@${i}"
  ]

  squid_connection_string = [
    for i in module.instance["squid"].public_ip :
      "ssh -i ${var.squid_ssh_user_private_key} ${module.ami.user}@${i}"
  ]

}

output "automate_ssh_command" {
  value = local.automate_connection_string
}

output "ingest_token" {
  value = module.automate_install.token
}

output "Automate_UI" {
  value = local.ui
}

output "squid_ssh_command" {
  value = local.squid_connection_string
}
