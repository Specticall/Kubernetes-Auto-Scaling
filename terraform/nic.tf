resource "azurerm_network_interface" "k8s-worker-nic" {
  name                = "k8s-worker-${random_integer.id.result}-nic"
  location            = azurerm_virtual_network.k8s-vnet-secondary.location
  resource_group_name = data.azurerm_resource_group.k8s-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.k8s-subnet-secondary.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.k8s-worker-ip.id
  }
}
