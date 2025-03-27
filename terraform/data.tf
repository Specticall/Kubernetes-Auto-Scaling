data "azurerm_resource_group" "k8s-rg" {
  name = "k8s-setup"
}

data "azurerm_virtual_network" "k8s-vn" {
  name                = "k8s-vnet"
  resource_group_name = data.azurerm_resource_group.k8s-rg.name
}

data "azurerm_network_security_group" "k8s-nsg" {
  name                = "k8s-nsg"
  resource_group_name = data.azurerm_resource_group.k8s-rg.name
}

data "azurerm_subnet" "k8s-subnet-1" {
  name                 = "k8s-subnet-1"
  resource_group_name  = data.azurerm_resource_group.k8s-rg.name
  virtual_network_name = data.azurerm_virtual_network.k8s-vn.name
}
