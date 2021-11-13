module "k8s-master" {
  source = "./instances/k8s-master"

  tenancy_id            = var.tenancy_id
  compartment_id        = var.compartment_id
  shape                 = var.shape
  source_ocid           = var.source_ocid
  subnet_id             = module.network.public-master-subnet-ocid
  ssh_public_keys       = var.ssh_public_keys
  instance_display_name = "k8s-master"

  depends_on = [
    module.network
  ]
}