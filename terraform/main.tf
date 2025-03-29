module "networks" {
  source = "./modules/networking"

  resource_group_name = local.resource_group_name
  for_each = local.workers_config

  master = {
    location = local.master.location
    vn_id    = local.master.vn_id
    vn_name  = local.master.vn_name
  }

  worker = {
    location      = each.key
    network_range = each.value.network_range
    subnet_range  = each.value.subnet_range
  }
}

module "vms" {
  source = "./modules/vms"

  resource_group_name = local.resource_group_name
  for_each = local.workers_config

  access = {
    admin_username = local.worker_vm_admin_username
    public_ssh_key_path = local.worker_vm_public_ssh_key_path
  }

  id_list = each.value.vm_ids
  vnet = {
    location = module.networks[each.key].worker_virtual_network.location
  }
  subnet = {
    id = module.networks[each.key].worker_subnet.id
  }
}
