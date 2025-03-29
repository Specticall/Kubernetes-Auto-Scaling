module "data" {
  source = "./modules/data"
}

locals {
  resource_group_name = module.data.k8s_rg.name
  master = {
    location = module.data.k8s_rg.location
    vn_id    = module.data.k8s_master_vn.id
    vn_name  = module.data.k8s_master_vn.name
  }
  workers_config = var.workers_config

  worker_vm_admin_username = "worker"
  worker_vm_public_ssh_key_path = "${path.root}/../secret/k8s-key.pub"
}
