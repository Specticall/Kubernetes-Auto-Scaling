resource "azurerm_public_ip" "k8s-worker-ip" {
  name                = "k8s-worker-${random_integer.id.result}-ip"
  location            = azurerm_virtual_network.k8s-vnet-secondary.location
  resource_group_name = data.azurerm_resource_group.k8s-rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "k8s-worker-ip" {
  name                = azurerm_public_ip.k8s-worker-ip.name
  resource_group_name = data.azurerm_resource_group.k8s-rg.name
}
