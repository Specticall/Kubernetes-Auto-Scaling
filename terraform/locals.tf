module "data" {
  source = "./modules/data"
}

locals {
  resource_group_name = module.data.k8s_rg.name
  bastion_subnet_range = "1.0.0.64/26"
  master = {
    location = module.data.k8s_rg.location
    vn_id    = module.data.k8s_master_vn.id
    vn_name  = module.data.k8s_master_vn.name
  }
  workers_config = var.workers_config

  bastion_vm_admin_username = "bastion"
  worker_vm_admin_username = "worker"

  public_ssh_key_path = "${path.root}/../secret/k8s-key.pub"
}
