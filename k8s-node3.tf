module "k8s-node3" {
  source = "./instances/k8s-node3"

  tenancy_id            = var.tenancy_id
  compartment_id        = var.compartment_id
  shape                 = var.shape
  source_ocid           = var.source_ocid
  subnet_id             = module.network.public-master-subnet-ocid
  ssh_public_keys       = var.ssh_public_keys
  instance_display_name = "k8s-node3"

  depends_on = [
    module.network,
    module.k8s-master,
    module.k8s-node1,
    module.k8s-node2
  ]
}