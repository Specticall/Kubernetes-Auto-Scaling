resource "azurerm_public_ip" "k8s_worker_ip" {
  for_each = toset(var.id_list)

  name                = "k8s-worker-${each.value}-ip"
  location            = var.vnet.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "k8s_worker_nic" {
  for_each = toset(var.id_list)

  name                = "k8s-worker-${each.value}-nic"
  location            = var.vnet.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.k8s_worker_ip[each.value].id
  }
}

resource "azurerm_linux_virtual_machine" "k8s_worker_vm" {
  for_each = toset(var.id_list)

  name                = "k8s-worker-${each.value}-vm"
  resource_group_name = var.resource_group_name

  location            = var.vnet.location
  size                = "Standard_F2"
  admin_username      = var.access.admin_username

  network_interface_ids = [
    azurerm_network_interface.k8s_worker_nic[each.value].id,
  ]

  admin_ssh_key {
    username = var.access.admin_username
    public_key = file(var.access.public_ssh_key_path)
  }

  os_disk {
    name                = "k8s-worker-${each.value}-osdisk"
    caching             = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
