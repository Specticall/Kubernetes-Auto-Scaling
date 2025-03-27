resource "azurerm_virtual_network" "k8s-vnet-secondary" {
  name                = "k8s-vnet-${var.region}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.k8s-rg.name
  address_space       = ["2.0.0.0/24"]
}

resource "azurerm_subnet" "k8s-subnet-secondary" {
  name                 = "k8s-subnet-${var.region}"
  resource_group_name  = data.azurerm_resource_group.k8s-rg.name
  virtual_network_name = azurerm_virtual_network.k8s-vnet-secondary.name
  address_prefixes     = ["2.0.0.0/25"]
}

resource "azurerm_virtual_network_peering" "eastasia_to_region" {
  name                         = "eastasia-to-${var.region}"
  resource_group_name          = data.azurerm_resource_group.k8s-rg.name
  virtual_network_name         = data.azurerm_virtual_network.k8s-vn.name
  remote_virtual_network_id    = azurerm_virtual_network.k8s-vnet-secondary.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "region_to_eastasia" {
  name                         = "${var.region}-to-eastasia"
  resource_group_name          = data.azurerm_resource_group.k8s-rg.name
  virtual_network_name         = azurerm_virtual_network.k8s-vnet-secondary.name
  remote_virtual_network_id    = data.azurerm_virtual_network.k8s-vn.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}
