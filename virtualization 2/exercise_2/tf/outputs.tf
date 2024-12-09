output "public_ip" {
  value       = azurerm_public_ip.public_ip.ip_address
  description = "The public IP address of the VM."
  depends_on  = [azurerm_linux_virtual_machine.vm]
}
