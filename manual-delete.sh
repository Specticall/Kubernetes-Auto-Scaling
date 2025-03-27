# Delete the eastasia-to-indonesia peering
az network vnet peering delete \
  --name eastasia-to-indonesia \
  --resource-group k8s-setup \
  --vnet-name k8s-vnet

# Delete the indonesia-to-eastasia peering
az network vnet peering delete \
  --name indonesia-to-eastasia \
  --resource-group k8s-setup \
  --vnet-name k8s-vnet-indonesia
