resource "azurerm_linux_virtual_machine" "k8s-vm-worker-extra" {
  name                = "k8s-vm-worker-${random_integer.id.result}"
  resource_group_name = data.azurerm_resource_group.k8s-rg.name
  location            = azurerm_virtual_network.k8s-vnet-secondary.location
  size                = "Standard_F2"
  admin_username      = "worker"
  network_interface_ids = [
    azurerm_network_interface.k8s-worker-nic.id,
  ]

  admin_ssh_key {
    username = "worker"
    # Reads a file and replaces this line with the content of the file
    public_key = file("../secret/k8s-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # provisioner "local-exec" {
  #   command = "wsl bash -c 'ANSIBLE_HOST_KEY_CHECKING=False sudo ansible-playbook -i ${self.public_ip_address}, -u worker --private-key /mnt/c/Users/ASUS/.ssh/practice_azure_key /mnt/c/Users/ASUS/Root/Programming/IT\\ AT/K8S\\ Autoscale/ansible/install-docker.yaml'"
  # }

  tags = {
    environment = "dev"
  }
}
