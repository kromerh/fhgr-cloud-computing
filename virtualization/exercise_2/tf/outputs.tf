output "public_ip" {
  value       = azurerm_public_ip.public_ip.ip_address
  description = "The public IP address of the VM."
}

output "ssh_command" {
  value       = "ssh azureuser@${azurerm_public_ip.public_ip.ip_address}"
  description = "SSH into the VM."
}

output "webshop_url" {
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:5000"
  description = "The webshop, a few minutes after the apply (the extension installs Flask first)."
}
