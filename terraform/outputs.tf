output "vm_ip" {
  value      = azurerm_linux_virtual_machine.k8s-vm-worker-extra.public_ip_address
}
