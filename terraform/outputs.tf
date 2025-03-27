output "vm_ip" {
  value      = data.azurerm_public_ip.k8s-worker-ip.ip_address
}
